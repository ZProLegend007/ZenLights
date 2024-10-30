# ZenLights
A collection of various random scripts designed to manipulate the controllable led backlights (not including display) on ZenBooks.

## Installation
You can fully customise and install these scripts to your `/usr/local/bin` directory using the command below **IN BETA - NOT WORKING YET**.
```
wget -q https://raw.githubusercontent.com/ZProLegend007/ZenLights/main/install.sh && bash install.sh
```
Or just download the script you want and run it.


### Requirements

These will be installed automatically installed using `install.sh` but if you are just using one script then you need to install these with your chosen package manager:

```
sudo apt install brightnessctl evtest i2c-tools python3 python3-numpy python3-pyaudio python3-libevdev
```


#### Adding touchpad backlight support (dance.sh, autobacklight.sh, spaz.sh): 

Credit: [asus-linux-drivers](https://github.com/asus-linux-drivers/asus-numberpad-driver)
```
git clone https://github.com/asus-linux-drivers/asus-numberpad-driver && cd asus-numberpad-driver && bash install.sh
```
<hr>

### kbvis.py
(in progress)
A customiseable audio visualiser that monitors audio output, calculates bass amplitude and then uses the keyboard backlight to let you experience your music on a whole new level.

### pulse.sh
A nice smooth script that makes the keyboard backlight pulse on each keypress.

### autobacklight.sh
Automatically triggers the keyboard and touchpad backlight to fade in on keypresses, will fade out after a very short time with no keypresses. This delay is configurable.

### dance.sh
A script to make all available leds (excluding display backlight) change to a random unique brightness setting on each keypress.

### spaz.sh
Literally the name. Sets all backlights (excluding display backlight) to a random value repetitively for 5 seconds.


