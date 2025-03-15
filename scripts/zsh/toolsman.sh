#!/usr/bin/env bash

##
# @brief Main function to apply image transformations using ascii-image-converter.
#
# This function allows users to select various image transformation options
# and apply them to a specified image using the ascii-image-converter tool.
# If no image path is provided, a default image is used.
#
# @param $1 [optional] Path to the image file. If not provided, a default image is used.
#
# @note The available transformation options are: color, color-bg, braille, dither,
#       grayscale, negative, complex, flipX, and flipY.
#
# @warning If the provided image path is not readable, the default image will be used.
#
# @example
#   toolsman /path/to/image.png
#
toolsman() {
    local options=(
      "color" "color-bg" "braille" "dither" "grayscale" "negative" "complex" "flipX" "flipY"
    )
    local selected_options=()
    local input
    local image_path="$HOME/.dotfiles/wallpapers/tools-man.png"  # Default path
    
    # Check if an image path was provided
    if [[ $# -gt 0 ]]; then
        # Verify the path exists and is readable
        if [[ -r "$1" ]]; then
            image_path="$1"
        else
            echo "Warning: Could not read image at '$1'. Using default image."
        fi
    fi
    
    # Display the numbered list
    echo "Available options:"
    for ((i=0; i<${#options[@]}; i++)); do
        echo "$((i+1)): ${options[i]}"
    done
    
    # Prompt for input string
    echo "Enter option numbers in one string (e.g., '123'):"
    read -r input
    
    # Process each digit in the input
    for ((i=0; i<${#input}; i++)); do
        local num="${input:$i:1}"
        # Check if the digit is valid and within range
        if [[ "$num" =~ ^[0-9]$ && "$num" -ge 1 && "$num" -le "${#options[@]}" ]]; then
            # Add the option using 0-based indexing
            selected_options+=("--${options[$((num-1))]}")
        else
            echo "Invalid option: $num - skipping"
        fi
    done
    
    # Run command with selected options
    if [[ ${#selected_options[@]} -gt 0 ]]; then
        echo "Running with options: ${selected_options[*]}"
        echo "Using image: $image_path"
        ascii-image-converter "$image_path" "${selected_options[@]}"
    else
        echo "No valid options selected."
    fi
}

toolsman $1
