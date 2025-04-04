# ArduPilot Scripts

## parabolic_drop.lua
A Lua script for ArduPilot to perform a parabolic payload drop during a mission.

### Features
- Calculates drop distance based on velocity and altitude.
- Controls a servo to release the payload at the calculated point.
- Returns the servo to a closed position after release.
- Resets for multiple missions on disarm.

### Usage
- Upload the Script to the Flight Controller
Insert the flight controller’s SD card into your computer.
Create a folder named APM/scripts on the SD card if it doesn’t exist.
Copy parabolic_drop.lua into the APM/scripts folder.
Safely eject the SD card and insert it back into the flight controller.

- Set `SERVO10_FUNCTION = 1` (or appropriate channel).
- Adjust `is_sitl` based on your environment (true for SITL, false for real hardware).
- Upload to your flight controller and run a mission.

