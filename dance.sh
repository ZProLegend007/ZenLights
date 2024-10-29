#!/bin/bash

# Get all LED devices excluding specified LEDs and the display backlight
leds=$(brightnessctl --list | grep -v 'intel_backlight' | grep -Ev 'compose|kana|scrolllock|numlock|phy0' | awk -F "'" '{print $2}')

# Declare associative arrays to store the previous brightness values
declare -A previous_brightness
declare -A initial_brightness
previous_touchpad_brightness=0  # Initialize previous touchpad brightness

# Function to restore brightness levels
restore_brightness() {
    for led in "${!initial_brightness[@]}"; do
        # Restore the brightness to the initial value
        brightnessctl -d "$led" s "${initial_brightness[$led]}" > /dev/null 2>&1
        echo "$led restored to ${initial_brightness[$led]}."
    done
    # Restore touchpad backlight to 0
    i2ctransfer -f -y 2 w13@0x15 0x05 0x00 0x3d 0x03 0x06 0x00 0x07 0x00 0x0d 0x14 0x03 0x00 0xad
    echo "Touchpad backlight restored to 0."
    exit 0  # Exit the script after restoring brightness
}

# Set up a trap to catch interrupt signals (SIGINT)
trap restore_brightness SIGINT

# Save the initial brightness levels
for led in $leds; do
    initial_brightness[$led]=$(brightnessctl -d "$led" g)
done

# Function to set random brightness for each LED, ensuring it's different from the previous one
set_random_brightness() {
    for led in $leds; do
        # Get the maximum brightness value for the LED
        max_brightness=$(brightnessctl -d "$led" m)

        # Ensure the max brightness is valid
        if [[ "$max_brightness" =~ ^[0-9]+$ ]] && [ "$max_brightness" -gt 0 ]; then
            new_brightness=$((RANDOM % (max_brightness + 1)))  # Generate random brightness

            # Ensure the new brightness is different from the previous one
            while [ "$new_brightness" -eq "${previous_brightness[$led]}" ]; do
                new_brightness=$((RANDOM % (max_brightness + 1)))  # Generate new random brightness
            done

            # Set the new random brightness for standard LEDs (suppressing output)
            brightnessctl -d "$led" s "$new_brightness" > /dev/null 2>&1

            # Display only the relevant output for standard LEDs
            echo "$led set to $new_brightness (max: $max_brightness)"
            # Update the previous brightness value for the current LED
            previous_brightness[$led]=$new_brightness
        else
            echo "Invalid max brightness for $led"
        fi
    done

    # Control the touchpad backlight as well
    touchpad_brightness_values=(0x01 0x60 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x00 0x61)
    current_index=0

    # Find the index of the previous touchpad brightness
    for i in "${!touchpad_brightness_values[@]}"; do
        if [[ "${touchpad_brightness_values[$i]}" == "$previous_touchpad_brightness" ]]; then
            current_index=$i
            break
        fi
    done

    # Generate a new index at least 2 positions away from the current one
    touchpad_brightness_count=${#touchpad_brightness_values[@]}
    new_index=$(( (current_index + 2 + RANDOM % (touchpad_brightness_count - 2)) % touchpad_brightness_count ))

    new_touchpad_brightness=${touchpad_brightness_values[$new_index]}

    # Send the command to change the touchpad backlight
    i2ctransfer -f -y 2 w13@0x15 0x05 0x00 0x3d 0x03 0x06 0x00 0x07 0x00 0x0d 0x14 0x03 $new_touchpad_brightness 0xad
    echo "Touchpad backlight set to $new_touchpad_brightness."

    # Update the previous touchpad brightness
    previous_touchpad_brightness=$new_touchpad_brightness
}

# Run in an infinite loop, change LED brightness on each keypress
while true; do
    read -n1 -s key  # Wait for a keypress
    set_random_brightness
done
