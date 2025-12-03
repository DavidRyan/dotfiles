# Sketchybar Aerospace Integration

This integration shows Aerospace workspaces in sketchybar instead of macOS spaces.

## Configuration Files

The integration consists of two main files:

1. **`~/.config/sketchybar/plugins/aerospace.sh`** - Script that updates the workspace appearance when focus changes
2. **`~/.aerospace.toml`** - Contains the callback to notify sketchybar of workspace changes

## How It Works

1. The sketchybarrc creates items for each Aerospace workspace on startup
2. When you switch workspaces, Aerospace triggers an event in sketchybar
3. Sketchybar updates the workspace indicators using the aerospace.sh plugin

## Customization

You can modify the appearance of workspaces by editing:
- Colors in your variables.sh file
- The styling in the sketchybarrc workspace section
- The highlighting behavior in the aerospace.sh script

## Troubleshooting

If workspaces aren't updating correctly:
1. Check that the `exec-on-workspace-change` callback is properly configured in ~/.aerospace.toml
2. Make sure sketchybar is subscribed to the aerospace_workspace_change event
3. Reload both sketchybar and Aerospace after making changes:
   ```
   sketchybar --reload
   aerospace reload-config
   ```