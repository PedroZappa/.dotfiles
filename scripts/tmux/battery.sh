#!/usr/bin/env bash

case "$(uname -s)" in
    Linux)
        cat /sys/class/power_supply/BAT0/capacity
        ;;
    Darwin)
        pmset -g batt | awk -F';' '/InternalBattery/ {
            gsub(/[^0-9]/, "", $2)
            print $2
        }'
        ;;
esac
