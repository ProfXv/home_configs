#!/usr/bin/env sh

PROJECT_DIR=~/Desktop/Projects

[ $# -gt 0 ] && {
    TARGET_DIR="$PROJECT_DIR/$1"
    shift

    [ -d "$TARGET_DIR" ] && {
        [ -f "$TARGET_DIR/main" ] && {
            chmod +x "$TARGET_DIR/main"

            if [ -f "$TARGET_DIR/.envrc" ]; then
                direnv exec "$TARGET_DIR" "$TARGET_DIR/main" "$@"
            else
                "$TARGET_DIR/main" "$@"
            fi
        } || {
            echo "Error: 'main' not found in $TARGET_DIR"
        }
    } || {
        echo "Error: Project not found: $TARGET_DIR"
    }
} || {
    echo "Usage: $0 <project> [args...]"
}

