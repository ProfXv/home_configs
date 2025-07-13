#!/bin/sh

eval "export GEMINI_API_KEY=\$GEMINI_API_KEY_$(printf "%s\n" {1..9} | fzf)"
if [ "$PROJECT_HOME" = "$HOME" ]; then gemini; else gemini -y; fi
