-- parabolic_drop.lua

-- Constants
local g = 9.81  -- gravity (m/s^2)
local drop_altitude = 30  -- target altitude in meters above waypoint
local min_start_altitude = 3.0  -- start calculating only above this
local payload_weight = 1.5  -- kg (optional)
local servo_channel = 10
local servo_release_pwm = 1800  -- Release PWM value (e.g., open position)
local servo_return_pwm = 1000  -- Return PWM value (e.g., closed position)
local drop_triggered = false
local message_counter = 0
local drop_state = 0  -- 0: idle, 1: release PWM, 2: return PWM
local drop_timer = 0  -- Timer to manage delays between states
local was_armed = false  -- Track arming state to detect disarm

-- Calculate ideal horizontal drop distance
local function calculate_drop_distance(velocity, altitude)
    return velocity * math.sqrt((2 * altitude) / g)
end

function update()
    message_counter = message_counter + 1

    if message_counter == 1 then
        gcs:send_text(4, "Parabolic drop script initialized")
    end

    -- Check arming state and reset drop_triggered on disarm
    local is_armed = arming:is_armed()
    if was_armed and not is_armed then
        drop_triggered = false
        drop_state = 0
        gcs:send_text(4, "Drop reset on disarm")
    end
    was_armed = is_armed

    if not is_armed then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Waiting for arming...")
        end
        return update, 1000
    end

    if drop_triggered then
        return update, 1000
    end

    if not ahrs:healthy() or not ahrs:get_position() then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Waiting for EKF position estimate...")
        end
        return update, 1000
    end

    local wp_index = mission:get_current_nav_index()
    if wp_index <= 1 then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Waiting for mission to start (WP > 1)...")
        end
        return update, 1000
    end

    local velocity_vector = ahrs:get_velocity_NED()
    if not velocity_vector then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Velocity NED not available")
        end
        return update, 1000
    end

    local velocity = math.sqrt(
        velocity_vector:x() * velocity_vector:x() +
        velocity_vector:y() * velocity_vector:y()
    )

    if velocity < 0.1 then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Waiting for velocity > 0.1 m/s...")
        end
        return update, 1000
    end

    local current_loc = ahrs:get_position()
    if not current_loc then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Position not available")
        end
        return update, 1000
    end

    local altitude = current_loc:alt() * 0.01  -- Convert cm to meters

    if altitude < min_start_altitude then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Altitude below 3m, waiting to climb...")
        end
        return update, 1000
    end

    local wp_item = mission:get_item(wp_index)
    if not wp_item then
        if message_counter % 5 == 0 then
            gcs:send_text(4, "Waypoint not found")
        end
        return update, 1000
    end
    
    local wp_location = Location()
    wp_location:lat(wp_item:x())
    wp_location:lng(wp_item:y())
    wp_location:alt(math.floor(wp_item:z() * 100))

    local dist_to_wp = current_loc:get_distance(wp_location)
    if message_counter % 5 == 0 then
        gcs:send_text(4, string.format("Dist to WP #%d: %.1f m", wp_index, dist_to_wp))
    end

    local relative_altitude = altitude - (wp_location:alt() * 0.01)
    if relative_altitude <= drop_altitude then
        if message_counter % 5 == 0 then
            gcs:send_text(4, string.format("Relative alt %.1f m <= drop alt %.1f m", relative_altitude, drop_altitude))
        end
        return update, 1000
    end

    local drop_distance = calculate_drop_distance(velocity, drop_altitude)
    if message_counter % 5 == 0 then
        gcs:send_text(4, string.format("Alt: %.1f m | Vel: %.1f m/s | DropDist: %.1f m", altitude, velocity, drop_distance))
    end

    -- State machine for drop sequence
    if dist_to_wp <= drop_distance and dist_to_wp > 0 then
        if drop_state == 0 then
            -- Step 1: Set release PWM (1800 µs)
            SRV_Channels:set_output_pwm_chan_timeout(servo_channel, servo_release_pwm, 1000)
            gcs:send_text(4, string.format("Payload dropped at %.1f m from WP!", dist_to_wp))
            gcs:send_text(4, string.format("Servo number is %.1f ", servo_channel))
            drop_state = 1
            drop_timer = 0
        elseif drop_state == 1 then
            -- Step 2: Wait for release to complete (1 second)
            drop_timer = drop_timer + 1
            if drop_timer >= 1 then  -- 1 cycle at 1000ms = 1 second
                -- Step 3: Set return PWM (1000 µs)
                SRV_Channels:set_output_pwm_chan_timeout(servo_channel, servo_return_pwm, 1000)
                gcs:send_text(4, string.format("Servo number is %.1f ", servo_channel))
                gcs:send_text(4, "Servo returned to closed position")
                drop_state = 2
                drop_triggered = true
            end
        end
    end

    return update, 1000
end

return update, 1000
