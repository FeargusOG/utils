#!/bin/sh

bat=$(/usr/bin/upower -i /org/freedesktop/UPower/devices/battery_BAT0 | /usr/bin/grep percentage | /usr/bin/awk '{print $2}' | /usr/bin/sed 's/%//')

if [ $bat -gt 80 ]
then
  XDG_RUNTIME_DIR=/run/user/$(id -u) /usr/bin/notify-send "Unplug Your Laptop!" "Battery % above 80%"
elif [ $bat -lt 20 ]
then
  XDG_RUNTIME_DIR=/run/user/$(id -u) /usr/bin/notify-send "Plug In Your Laptop!" "Battery % below 20%"
fi
