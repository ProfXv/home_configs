#!/bin/sh

SHELL='which bash'
AUTO="--permission-mode acceptEdits"
BASIC="--chrome --betas interleaved-thinking --allow-dangerously-skip-permissions"

has_claude_conversation() {
    cwd="$(pwd -P)" || return 1
    [ -z "$cwd" ] && return 1

    # Convert path to project directory name
    if command -v python3 >/dev/null 2>&1; then
        dir_name="$(python3 -c "import sys,re; print(re.sub(r'[^a-zA-Z0-9]', '-', sys.argv[1]))" "$cwd")"
    elif command -v perl >/dev/null 2>&1; then
        dir_name="$(echo "$cwd" | perl -CSD -pe 's/[^a-zA-Z0-9]/-/g')"
    else
        dir_name="$(echo "$cwd" | sed 's/[^a-zA-Z0-9]/-/g')"
    fi

    proj_dir="$HOME/.claude/projects/$dir_name"
    [ -r "$proj_dir" ] || return 1

    for jsonl_file in "$proj_dir"/*.jsonl; do
        [ -f "$jsonl_file" ] || continue
        [ -s "$jsonl_file" ] || continue

        if grep -q "\"cwd\":\"$cwd\"" "$jsonl_file" 2>/dev/null; then
            if grep -q '"type":"user"' "$jsonl_file" && \
               grep '"type":"user"' "$jsonl_file" | grep -q -v '"content":"Warmup"'; then
                return 0
            fi
        fi
    done

    return 1
}

case "$PROJECT_HOME" in
    $HOME/Desktop/Projects/*)
        has_claude_conversation && claude -r $AUTO $BASIC || claude $AUTO $BASIC
        ;;
    *)
        has_claude_conversation && claude -r $BASIC || claude $BASIC
        ;;
esac
