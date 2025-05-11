#!/bin/sh
# This is a shell script to check Wi-Fi status and output icon, ESSID, 
# or color based on the connection state.

# Check if the network is disconnected by searching for "disconnected" 
# in the output of `nmcli g`
status=$(nmcli g | grep -oE "disconnected")

# Get the ESSID of the currently connected Wi-Fi network
# - `nmcli -t -f active,ssid dev wifi` lists Wi-Fi networks with their active status
# - `grep '^yes'` filters only the active (connected) network
# - `cut -d: -f2` extracts the ESSID (network name)
essid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# If the status variable is not empty (i.e., "disconnected" was found)
if [ $status ] ; then
    icon="睊"        # Set icon to indicate disconnected state
    text=""          # No ESSID to display when disconnected
else
    icon=""         # Set icon to indicate connected state (Wi-Fi symbol)
    text="${essid}"  # Display the ESSID of the connected network
fi

# Output the requested value based on the first argument to the script
case $1 in
    --ICON) echo $icon;;   # Output the icon
    --ESSID) echo $text;;  # Output the ESSID (network name)
esac
