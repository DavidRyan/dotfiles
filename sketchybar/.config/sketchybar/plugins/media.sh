#!/usr/bin/env bash

# Unified media plugin - works with Spotify, YouTube Music (Chrome), Apple Music, etc.
# Popup is handled by Hammerspoon

ARTWORK_PATH="/tmp/sketchybar_media_artwork.jpg"

# Get media info from nowplaying-cli
TITLE=$(nowplaying-cli get title 2>/dev/null)
ARTIST=$(nowplaying-cli get artist 2>/dev/null)
APP=$(nowplaying-cli get appBundleIdentifier 2>/dev/null)

# If no title, just exit without changing anything (keep previous state)
if [ "$TITLE" = "null" ] || [ "$TITLE" = "" ]; then
    exit 0
fi

# Extract and save album artwork for Hammerspoon popup
ARTWORK_DATA=$(nowplaying-cli get artworkData 2>/dev/null)
if [ "$ARTWORK_DATA" != "null" ] && [ -n "$ARTWORK_DATA" ]; then
    echo "$ARTWORK_DATA" | base64 -d > "$ARTWORK_PATH" 2>/dev/null
fi

# Set icon based on app
case "$APP" in
    "com.spotify.client")
        ICON="󰓇"
        ;;
    "com.google.Chrome"|"com.google.Chrome.canary")
        ICON=""
        ;;
    "com.apple.Music")
        ICON="󰎆"
        ;;
    "com.brave.Browser")
        ICON=""
        ;;
    "org.mozilla.firefox")
        ICON="󰈹"
        ;;
    "com.apple.Safari")
        ICON="󰀹"
        ;;
    *)
        ICON="󰎈"
        ;;
esac

# Format the label for main widget
if [ "$ARTIST" != "null" ] && [ "$ARTIST" != "" ]; then
    MEDIA="$TITLE - $ARTIST"
else
    MEDIA="$TITLE"
fi

# Update main widget
sketchybar --set "$NAME" label="$MEDIA" icon="$ICON" drawing=on
