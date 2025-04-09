# AUX9 PWM Control Script for ArduPilot

This Lua script toggles the PWM output on a selected servo channel (default: channel 7) between a low and high value with a delay in between. It's designed for use on AUX outputs (e.g., AUX9 on a Pixhawk flight controller).

---

## 📌 Script Features

- Sends a **LOW PWM (1000 µs)** followed by a **HIGH PWM (1800 µs)**.
- Repeats this cycle continuously.
- Uses ArduPilot's Lua scripting engine.

---

## 🛠 Configuration

### Parameters in Script

| Variable         | Description                                 | Default     |
|------------------|---------------------------------------------|-------------|
| `servo_channel`  | Servo output channel (e.g., 7 = AUX7)        | `7`         |
| `pwm_value_low`  | Low PWM value (closed position)              | `1000`      |
| `pwm_value_high` | High PWM value (open position)               | `1800`      |
| `pulse_time_ms`  | Duration each PWM state is held (ms)         | `1000`      |

---

## 🚀 How to Use

### 1. **Save the Script**
Save the script as `aux9_pwm_control.lua`.

### 2. **Upload to ArduPilot**

- Use **Mission Planner** or **QGroundControl**.
- Place the file in the appropriate script slot:

  For **Mission Planner**:
  - Go to **"Config/Tuning" > "Scripting"**
  - Upload the `.lua` file to `/scripts/` folder

  For **SD card method**:
  - Place the `.lua` file in `/APM/scripts/` directory on the SD card inserted into the flight controller.

### 3. **Enable Lua Scripting**
Make sure scripting is enabled in your parameters:

| Parameter         | Value   |
|------------------|---------|
| `SCR_ENABLE`      | `1`     |
| `SCR_DIR`         | `"scripts"` (or as appropriate) |

### 4. **Connect to GCS**
Open **Mission Planner's Messages tab** or **QGC MAVLink Inspector** to view GCS text messages confirming PWM operations.

---

## 🧪 Output Behavior

Every 2 seconds, the script:
1. Sets servo channel to **LOW** (`1000 µs`)
2. Waits for `pulse_time_ms` (default: 1 second)
3. Sets it to **HIGH** (`1800 µs`)
4. Repeats the cycle

You will see messages like:


---

## 🧰 Troubleshooting

| Issue                              | Fix                                                             |
|-----------------------------------|------------------------------------------------------------------|
| No PWM on AUX port                | Make sure the channel is enabled as a `SERVOx_FUNCTION = -1`    |
| Script not running                | Check `SCR_ENABLE = 1` and confirm script is uploaded properly   |
| Wrong PWM channel                 | Adjust `servo_channel` in the script (e.g., AUX9 = channel 10)   |

---

## 📎 Notes

- You can change `servo_channel` to control a different AUX output.
- For one-time trigger instead of looping, remove the `state = 0` line.
- This is useful for activating mechanisms like payload drops, camera shutters, relays, etc.

---

## 🧠 Reference

- [ArduPilot Lua Scripting Docs](https://ardupilot.org/copter/docs/common-lua-scripts.html)
- [SERVOx_FUNCTION parameter reference](https://ardupilot.org/copter/docs/common-servo.html)
