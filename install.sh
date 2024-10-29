#!/bin/bash
clear
cat << "EOF"
  ______          _      _       _     _       
 |___  /         | |    (_)     | |   | |      
    / / ___ _ __ | |     _  __ _| |__ | |_ ___ 
   / / / _ \ '_ \| |    | |/ _` | '_ \| __/ __|
  / /_|  __/ | | | |____| | (_| | | | | |_\__ \
 /_____\___|_| |_|______|_|\__, |_| |_|\__|___/
                            __/ |              
                           |___/                   
EOF
# Install necessary requirements
echo "Installing requirements..."
sudo apt install -y brightnessctl evtest i2c-tools python3 python3-numpy python3-pyaudio python3-libevdev git

# Clone the repository
echo "Cloning ZenLights repository..."
git clone https://github.com/ZProLegend007/ZenLights.git
cd ZenLights

# Create the /etc/zenlights directory if it does not exist
sudo mkdir -p /etc/zenlights

# Move scripts to the appropriate directories
echo "Moving scripts..."
sudo mv zenlights /usr/local/bin/
sudo chmod +x /usr/local/bin/zenlights
sudo mv dance.sh kbvis.py pulse.sh autobacklight.sh spaz.sh /etc/zenlights/
sudo chmod +x /etc/zenlights/*.sh

# Ask for touchpad backlight support installation
while true; do
    echo "Do you want to install touchpad backlight support? (y/n)"
    read yn
    case $yn in
        [Yy]* )
            echo "Installing touchpad backlight support..."
            git clone https://github.com/asus-linux-drivers/asus-numberpad-driver
            cd asus-numberpad-driver
            bash install.sh
            cd ..
            rm -rf asus-numberpad-driver
            break
            ;;
        [Nn]* )
            echo "Skipping touchpad backlight support installation."
            break
            ;;
        * )
            echo "Please answer y or n."
            ;;
    esac
done
clear
cat << "EOF"
  ______          _      _       _     _       
 |___  /         | |    (_)     | |   | |      
    / / ___ _ __ | |     _  __ _| |__ | |_ ___ 
   / / / _ \ '_ \| |    | |/ _` | '_ \| __/ __|
  / /_|  __/ | | | |____| | (_| | | | | |_\__ \
 /_____\___|_| |_|______|_|\__, |_| |_|\__|___/
                            __/ |              
                           |___/                   
EOF
echo "Installation complete."
