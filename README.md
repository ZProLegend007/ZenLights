# ZenLights
A collection of various random scripts designed to manipulate the controllable led backlights (not including display) on ZenBooks.

The idea is that once you have installed the `zenlights` command (or just a script of your choice), you can set keyboard shortcuts to trigger specific scripts.

For example, you could assign Ctrl+Alt+P to run the command `zenlights pulse` to activate the pulse effect on your keyboard. You could then assign Ctrl+Alt+Shift+P to run `zenlights -k` to kill the running script.

## Installation
You  can easily install ZenLights using the command below.
```
wget -q https://raw.githubusercontent.com/ZProLegend007/ZenLights/main/install.sh && bash install.sh
```
This will install the `zenlights` command to your `/usr/local/bin` directory for easy usage and the scripts will be installed to `/etc/zenlights` where they can be called upon by the main command when needed.

Or just download the script you want and run it.

### Requirements

The `zenlights` command will be installed automatically using `install.sh` but if you are just using one script then you need to install these with your chosen package manager:

```
sudo apt install brightnessctl evtest i2c-tools python3 python3-numpy python3-pyaudio python3-libevdev
```


#### Adding touchpad backlight support (dance.sh, autobacklight.sh, spaz.sh): 

Credit: [asus-linux-drivers](https://github.com/asus-linux-drivers/asus-numberpad-driver)
```
git clone https://github.com/asus-linux-drivers/asus-numberpad-driver && cd asus-numberpad-driver && bash install.sh
```
<hr>

### kbvis
(in progress)
A customiseable audio visualiser written in rust that monitors audio output, calculates bass amplitude and then uses the keyboard backlight to let you experience your music on a whole new level.

### pulse.sh
A nice smooth script that makes the keyboard backlight pulse on each keypress.

### autobacklight.sh
Automatically triggers the keyboard and touchpad backlight to fade in on keypresses, will fade out after a very short time with no keypresses. This delay is configurable.

### dance.sh
A script to make all available leds (excluding display backlight) change to a random unique brightness setting on each keypress.

### spaz.sh
Literally the name. Sets all backlights (excluding display backlight) to a random value repetitively for 5 seconds.


