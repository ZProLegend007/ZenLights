#!/bin/bash

# Flags and timing settings
pulse_running=false
fade_in_complete=false
inactivity_timeout=0.5  # Time in seconds to wait before fading out after inactivity
last_keypress_time=0

# Function to pulse the keyboard backlight (fade in only)
pulse_keyboard() {
    max_brightness_kb=3  # Maximum brightness for the keyboard backlight
    steps=$((max_brightness_kb + 1))

    keyboard_speed=$(echo "0.01 * 8 / $steps" | bc -l)

    for i in $(seq 0 $((steps-1))); do
        brightnessctl -d "asus::kbd_backlight" s "$i" > /dev/null 2>&1
        sleep "$keyboard_speed"
    done

    fade_in_complete=true
}

# Function to pulse the touchpad backlight (fade in only)
pulse_touchpad() {
    touchpad_brightness_values=(0x48 0x47 0x46 0x45 0x44 0x43 0x42 0x41)
    steps=${#touchpad_brightness_values[@]}

    sleep 0.075

    for i in $(seq 0 $((steps-1))); do
        i2ctransfer -f -y 2 w13@0x15 0x05 0x00 0x3d 0x03 0x06 0x00 0x07 0x00 0x0d 0x14 0x03 ${touchpad_brightness_values[$i]} 0xad
        sleep 0.013
    done
}

# Function to fade out the keyboard backlight
fade_out_keyboard() {
    max_brightness_kb=3
    steps=$((max_brightness_kb + 1))
    keyboard_speed=$(echo "0.01 * 8 / $steps" | bc -l)

    for i in $(seq $((steps-1)) -1 0); do
        brightnessctl -d "asus::kbd_backlight" s "$i" > /dev/null 2>&1
        sleep "$keyboard_speed"
    done
}

# Function to fade out the touchpad backlight
fade_out_touchpad() {
    touchpad_brightness_values=(0x00 0x48 0x47 0x46 0x45 0x44 0x43 0x42 0x41)
    steps=${#touchpad_brightness_values[@]}

    sleep 0.02

    for i in $(seq $((steps-1)) -1 0); do
        i2ctransfer -f -y 2 w13@0x15 0x05 0x00 0x3d 0x03 0x06 0x00 0x07 0x00 0x0d 0x14 0x03 ${touchpad_brightness_values[$i]} 0xad
        sleep 0.013
    done
}

# Function to handle cleanup on exit
cleanup() {
    echo "Cleaning up..."
        fade_out_keyboard &
        fade_out_touchpad &
        wait
    exit 0
}

# Trap SIGINT (Ctrl+C) to call cleanup
trap cleanup SIGINT

# Main loop to trigger the pulse effect on keypress
while true; do
    # Use evtest to monitor keypress events
    evtest /dev/input/event3 | while read line; do
        if echo "$line" | grep -q "KEY_"; then
            if [ "$pulse_running" = false ]; then
                pulse_running=true
                pulse_keyboard &
                pulse_touchpad &
                wait
            fi

            last_keypress_time=$(date +%s.%N)

            # Check for inactivity
            while true; do
                read -t 0.1 line
                if [ $? -eq 0 ]; then
                    last_keypress_time=$(date +%s.%N)
                fi

                current_time=$(date +%s.%N)
                elapsed_time=$(echo "$current_time - $last_keypress_time" | bc)

                if (( $(echo "$elapsed_time >= $inactivity_timeout" | bc -l) )); then
                    fade_out_keyboard &
                    fade_out_touchpad &
                    wait
                    pulse_running=false
                    break
                fi
            done
        fi
    done
done
