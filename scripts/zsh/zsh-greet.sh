#!/usr/bin/env bash

HOST=$1

# Use proper ANSI C-quoted escape characters
ESC1=$'\001'
ESC2=$'\002'

# Wrap color codes with non-printing markers
GRA="${ESC1}$(tput setaf 243)${ESC2}"
MAG="${ESC1}$(tput setaf 5)${ESC2}"
CYN="${ESC1}$(tput setaf 6)${ESC2}"
D="${ESC1}$(tput sgr0)${ESC2}"

PAD="ꔘ ꔘ ꔘ "
PAD_LENGTH=${#PAD}
PADCHAR="ꔘ"

# Construct message with color codes
YO="Yo ${CYN}$USER!${D} Welcome to ${MAG}$HOST${D} "

# Calculate VISIBLE length (ignore escape sequences)
YO_VISIBLE=$(echo -en "$YO" | sed -e "s/$ESC1[^$ESC2]*$ESC2//g")
YO_LENGTH=${#YO_VISIBLE}

# Generate bookend line
BOOKEND=$(for (( i = 0; i < 2 * (YO_LENGTH - PAD_LENGTH - 1); i++ )); do
    if (( i % 2 == 0 )); then
        echo -n "$PADCHAR"
    else
        echo -n "${GRA}${PADCHAR}${D}"
    fi
done)

# Print the final result
echo "$BOOKEND"
echo " $PAD$YO$PAD"
echo "$BOOKEND"
