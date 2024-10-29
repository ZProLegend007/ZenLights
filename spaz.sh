#!/bin/bash

# Function to set all devices to maximum brightness
set_max_brightness() {
  for device in $(brightnessctl --list | grep 'Device' | awk -F\' '{print $2}'); do
    brightnessctl --device="$device" set 100% 2>/dev/null
  done
}

# Function to set all devices to minimum brightness
set_min_brightness() {
  for device in $(brightnessctl --list | grep 'Device' | awk -F\' '{print $2}'); do
    brightnessctl --device="$device" set 1% 2>/dev/null
  done
}

# End time calculation
end_time=$((SECONDS + 5))

# Loop to alternate brightness
while [ $SECONDS -lt $end_time ]; do
  set_max_brightness
  set_min_brightness
done
