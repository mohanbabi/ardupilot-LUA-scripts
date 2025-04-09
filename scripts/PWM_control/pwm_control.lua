-- aux9_pwm_control.lua

-- Channel 10 = AUX9 (AUX1 = 9, AUX9 = 10)
local servo_channel = 7
local pwm_value_high = 1800
local pwm_value_low = 1000
local pulse_time_ms = 1000  -- Duration for each state

local state = 0
local timestamp = 0

function update()
    local now = millis()

    if state == 0 then
        -- Step 1: Set to low PWM
        SRV_Channels:set_output_pwm_chan_timeout(servo_channel, pwm_value_low, pulse_time_ms)
        gcs:send_text(6, string.format("Set AUX9 (ch%d) to LOW PWM %d", servo_channel, pwm_value_low))
        timestamp = now
        state = 1
    elseif state == 1 and now - timestamp >= pulse_time_ms then
        -- Step 2: Set to high PWM after delay
        SRV_Channels:set_output_pwm_chan_timeout(servo_channel, pwm_value_high, pulse_time_ms)
        gcs:send_text(6, string.format("Set AUX9 (ch%d) to HIGH PWM %d", servo_channel, pwm_value_high))
        state = 0
    end

    return update, 2000 -- Check every 100ms for better timing resolution
end

return update, 100
