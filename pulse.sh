#!/bin/bash

pulse_keyboard() {
        brightnessctl -d "asus::kbd_backlight" s 3
}
pk() {
   max_brightness_kb=3
    steps=$((max_brightness_kb + 1))
    keyboard_speed=$(echo "0.005 * 8 / $steps" | bc -l)
    for i in $(seq $((steps-1)) -1 0); do
        brightnessctl -d "asus::kbd_backlight" s $i > /dev/null 2>&1
    done
}

# Function to handle cleanup on exit
cleanup() {

    exit 0
}

# Trap SIGINT (Ctrl+C) to call cleanup
trap cleanup SIGINT
# Main loop to trigger the pulse effect on keypress
while true; do
    # Use evtest to monitor keypress events
   while true; do
 if evtest /dev/input/event3 | grep -q -e "KEY_.*value 0"; then
                pulse_keyboard &
pk &
fi
             break
             while true; do
                read -t 0.1 line
             done
     done
done
