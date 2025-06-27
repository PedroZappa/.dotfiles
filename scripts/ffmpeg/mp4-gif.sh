#!/usr/bin/env bash
# set -euo pipefail

# Files
INPUT=$1
NAME="${INPUT%.*}"
OPTMZD="$NAME-optimized.gif"
OUTPUT="$NAME.gif"
# Params
FPS=10
SCALE=$2:-1

echo "Converting $INPUT to $OUTPUT"

# Generate color palette
if [ ! -f palette.png ]; then
	ffmpeg -i $INPUT -filter_complex "[0:v] palettegen" palette.png
fi
# Convert to GIF with:  
#	* a custom palette
#	* custom scale
#	* custom FPS
ffmpeg -i $INPUT -i palette.png \
	-filter_complex "[0:v] fps=$FPS,scale=$SCALE [new];[new][1:v] paletteuse" \
	$OPTMZD

# Compression & more compression
gifsicle -O3 --lossy=100 $OPTMZD -o $OUTPUT
