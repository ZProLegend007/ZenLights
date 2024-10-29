#!/bin/bash

# Install necessary requirements
echo "Installing requirements..."
sudo apt install -y brightnessctl evtest i2c-tools python3 python3-numpy python3-pyaudio python3-libevdev

# Ask for touchpad backlight support installation
read -p "Do you want to install touchpad backlight support? (y/n): " yn
case $yn in
    [Yy]* )
        echo "Installing touchpad backlight support..."
        git clone https://github.com/asus-linux-drivers/asus-numberpad-driver
        cd asus-numberpad-driver
        bash install.sh
        cd ..
        rm -rf asus-numberpad-driver
        ;;
    [Nn]* )
        echo "Skipping touchpad backlight support installation."
        ;;
    * )
        echo "Invalid input. Skipping touchpad backlight support installation."
        ;;
esac

echo "Installation complete."
