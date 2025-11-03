#!/bin/sh

number=`gemini_usage.awk ~/.gemini_usage.tsv | column -t | fzf | awk '{print $1}'`
eval export GEMINI_API_KEY=\$GEMINI_API_KEY_$number
model=`printf "pro\nflash" | fzf` && model="gemini-2.5-"$model
if [ "$PROJECT_HOME" = "$HOME" ]; then gemini -m $model; else gemini -ym $model; fi
