#!/bin/bash

# cowsay flavors
cmds=(cowsay cowthink)
# FaceMod flags
flags=(-b -d -g -s -t -w -y)
# Get available cowfiles with command: cowsay --list
cowfiles=(
alpaca beavis.zen blowfish bong bud-frogs bunny cheese cower cupcake daemon
default dragon dragon-and-cow elephant elephant-in-snake eyes flaming-sheep
fox ghostbusters head-in hellokitty kiss kitty koala kosh llama luke-koala
mech-and-cow meow milk moofasa moose mutilated ren sheep skeleton small
stegosaurus stimpy supermilker surgery three-eyes turkey turtle tux udder
vader vader-koala www
)

# Boxes designs
DESIGNS=(
  ada-box ada-cmt
  ansi ansi-dashed ansi-double ansi-heavy ansi-heavy-dashed
  ansi-rounded ansi-rounded-dashed
  bear boxquote boy 
  c c-cmt c-cmt2 caml
  capgirl cat cc
  columns cowsay critical diamonds dog dragon
  f90-box f90-cmt
  face fence girl
  headline html html-cmt
  ian_jones important important2 important3 info
  java-cmt java-doc js-tone lisp-cmp
  mouuse normand nuke parchment peek
  pound-cmt right santa scroll scroll-akn
  shell simple spring stark1 stark2 stone sunset
  tex-box tex-cmt tux twisted underline 
  unicornsay unicornthink 
  vim-box vim-cmt warning weave whirly xes
)


# Check fortune
if command -v fortune > /dev/null 2>&1; then
	# Get random fortune
	message="$(fortune)"
else
	message="No fortune 🥠"
fi

if (( RANDOM % 2 )); then
  # Check cowsay & fortune
  if command -v fortune > /dev/null 2>&1 && command -v boxes > /dev/null 2>&1; then
    DESIGN=${DESIGNS[$RANDOM % ${#DESIGNS[@]}]}
    echo "$(echo "$message" | boxes --align=c --color --design=$DESIGN)"
  fi
else
  if command -v fortune > /dev/null 2>&1 && command -v cowsay > /dev/null 2>&1; then
    cmd_len=${#cmds[@]}						# Get cmd_len of cmd array
    flags_len=${#flags[@]}					# Get flags_len of flags array
    cowfiles_len=${#cowfiles[@]}			# Get cowfiles_len of cowfiles array

    cmd_i=$((RANDOM % cmd_len))				# Get random cow_i
    flags_i=$((RANDOM % flags_len))			# Get random flags_i
    cow_i=$((RANDOM % cowfiles_len))		# Get random cow_i

    cmd=${cmds[$cmd_i]}						# Get random cmd
    flag=${flags[$flags_i]}					# Get random flag
    cowfile=${cowfiles[$cow_i]}				# Get random cow

    echo "$($cmd $flag -f $cowfile $message)"
    printf "$cmd $flag -f $cowfile +fortune\n"
  else
    printf "$message, no cowsay 🐄\n"
  fi
fi
