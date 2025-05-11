#!/bin/bash

## Files and cmd
CONF_DIR="$HOME/.config/eww"
EWW="eww -c $CONF_DIR"

## Run eww daemon if not running already
if [[ ! $(pidof eww) ]]; then
    ${EWW} daemon
    sleep 1
fi

# Read the list of windows into an array (one per line)
readarray -t WIDGETS < <(${EWW} list-windows)  # Bash 4+ required[1][4][6]

# Only open if there are any windows
if [[ ${#WIDGETS[@]} -gt 0 ]]; then
    ${EWW} open-many "${WIDGETS[@]}"           # Pass each window as a separate argument[2][6]
fi
