#!/usr/bin/env bash

COLOR="$RED"

# Main media item - clicks trigger Hammerspoon popup
sketchybar --add item media right \
	--set media \
	scroll_texts=off \
	icon=󰎆 \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	background.color="$BAR_COLOR" \
	background.height=26 \
	background.corner_radius="$CORNER_RADIUS" \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$COLOR" \
	background.padding_right=5 \
	background.drawing=on \
	label.padding_right=10 \
	label.max_chars=30 \
	label.color="$COLOR" \
	associated_display=active \
	updates=on \
	update_freq=3 \
	click_script="/opt/homebrew/bin/hs -c 'toggleMediaPopup()'" \
	script="$PLUGIN_DIR/media.sh" \
	--subscribe media media_change
