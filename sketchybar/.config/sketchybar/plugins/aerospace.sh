#!/usr/bin/env bash

# This script is called when an Aerospace workspace change is detected
source "$HOME/.config/sketchybar/variables.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME label.color="$RED" background.drawing=on
else
    sketchybar --set $NAME label.color="$COMMENT" background.drawing=off
fi