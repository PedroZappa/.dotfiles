#!/usr/bin/env bash
# Simple Stopwatch Script
# Press Ctrl+C to stop the timer.
#

# Load Colors
if [ -d ~/.dotfiles ]; then
    source ~/.dotfiles/scripts/colors.sh
else
    if [ ! -f ~/colors.sh ]; then
        echo -e "${YEL}Colors script not found, downloading: ${D}"
        wget https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/colors.sh
    fi
    source ./colors.sh
fi

seconds=0

# Catch Ctrl+C (SIGINT) and exit gracefully.
trap "echo; exit" SIGINT

while true; do
  # Calculate hours, minutes, and seconds.
  hrs=$(( seconds / 3600 ))
  mins=$(( (seconds % 3600) / 60 ))
  secs=$(( seconds % 60 ))
  
  # Print the elapsed time in hh:mm:ss format on the same line.
  printf "\r${BGRN}%02d:%02d:%02d${D}" "$hrs" "$mins" "$secs" 
  
  sleep 1
  seconds=$(( seconds + 1 ))
done

