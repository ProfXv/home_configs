#!/bin/sh

# Smart pause handler
# Detects the current active window and sends appropriate shortcut to quit/pause
# Designed to be triggered by a keybinding (e.g., pause key)

# Set default window manager settings (matching original socket.sh behavior)
hyprctl keyword input:follow_mouse 1
hyprctl keyword decoration:rounding 10
hyprctl keyword decoration:inactive_opacity .5
hyprctl keyword decoration:blur:enabled true

# Get active window information as JSON
window_json=$(hyprctl activewindow -j 2>/dev/null)
if [ -z "$window_json" ]; then
    exit 1
fi

# Extract class and pid
class=$(echo "$window_json" | jq -r '.class')
pid=$(echo "$window_json" | jq -r '.pid')

# Default to escape key
modifier=""
key="escape"

case "$class" in
    kitty)
        # For kitty terminal, analyze process tree to determine foreground program
        if [ -n "$pid" ] && [ "$pid" -gt 0 ]; then
            # Get process tree and extract the last process name
            proc_name=$(pstree -T "$pid" 2>/dev/null | grep -o '[^-]*$')
            case "$proc_name" in
                vi*|vim*|nvim*)
                    # vim/nvim: send escape
                    modifier=""
                    key="escape"
                    ;;
                yazi*|btop*|man*|more*|less*|git\ diff*)
                    # These programs quit with 'q'
                    modifier=""
                    key="q"
                    ;;
                *)
                    # Default for kitty: Ctrl+d (exit shell)
                    modifier="CTRL"
                    key="d"
                    ;;
            esac
        fi
        ;;
    nyxt)
        # Nyxt browser: Ctrl+w to close tab
        modifier="CTRL"
        key="w"
        ;;
    )
        # Special program: disable follow mouse, no shortcut sent
        hyprctl keyword input:follow_mouse 0
        # Exit without sending a shortcut
        exit 0
        ;;
    crystal-board)
        # Crystal board: special decoration settings + escape
        hyprctl keyword decoration:rounding 0
        hyprctl keyword decoration:inactive_opacity 1
        hyprctl keyword decoration:blur:enabled false
        modifier=""
        key="escape"
        ;;
    *)
        # Default for other windows: escape
        modifier=""
        key="escape"
        ;;
esac

hyprctl dispatch sendshortcut $modifier, $key,