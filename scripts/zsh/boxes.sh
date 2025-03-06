#!/usr/bin/env bash

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

DESIGN=${DESIGNS[$RANDOM % ${#DESIGNS[@]}]}

echo "Box Test" | \
  boxes --align=c \
    --color \
    --design=$DESIGN \
    --indent=box \


