#!/usr/bin/env bash

# Debug
echo "CLICK_X=$CLICK_X WIDTH=$WIDTH INFO=$INFO" >> /tmp/sketchybar_media_debug.log

# Horizontal controls: detect click position relative to item
# Item width is ~150px, split into 3 zones: prev (left third), play (middle), next (right third)

# Get item bounds from sketchybar
BOUNDS=$(sketchybar --query media.controls | grep -A4 '"origin"' | grep -oE '[0-9.]+' | head -1)

# Use WIDTH if available, otherwise default
ITEM_WIDTH=${WIDTH:-150}
ZONE_WIDTH=$((ITEM_WIDTH / 3))

# Calculate relative X position
if [ -n "$CLICK_X" ]; then
    REL_X=$CLICK_X
elif [ -n "$INFO" ]; then
    # Try to parse from INFO
    REL_X=$(echo "$INFO" | jq -r '.x // empty' 2>/dev/null)
fi

echo "REL_X=$REL_X ZONE_WIDTH=$ZONE_WIDTH" >> /tmp/sketchybar_media_debug.log

if [ -n "$REL_X" ]; then
    if [ "$REL_X" -lt "$ZONE_WIDTH" ] 2>/dev/null; then
        echo "ACTION=previous" >> /tmp/sketchybar_media_debug.log
        nowplaying-cli previous
    elif [ "$REL_X" -lt $((ZONE_WIDTH * 2)) ] 2>/dev/null; then
        echo "ACTION=togglePlayPause" >> /tmp/sketchybar_media_debug.log
        nowplaying-cli togglePlayPause
    else
        echo "ACTION=next" >> /tmp/sketchybar_media_debug.log
        nowplaying-cli next
    fi
else
    echo "ACTION=fallback togglePlayPause" >> /tmp/sketchybar_media_debug.log
    nowplaying-cli togglePlayPause
fi
