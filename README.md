# ArduPilot Scripts

## parabolic_drop.lua
A Lua script for ArduPilot to perform a parabolic payload drop during a mission.

### Features
- Calculates drop distance based on velocity and altitude.
- Controls a servo to release the payload at the calculated point.
- Returns the servo to a closed position after release.
- Resets for multiple missions on disarm.

### Usage
- Set `SERVO10_FUNCTION = 1` (or appropriate channel).
- Adjust `is_sitl` based on your environment (true for SITL, false for real hardware).
- Upload to your flight controller and run a mission.
