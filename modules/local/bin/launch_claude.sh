#!/bin/sh

AUTO="--permission-mode acceptEdits"
case "$PROJECT_HOME" in
    $HOME/Desktop/Projects/*)
        claude -r $AUTO || claude $AUTO
        ;;
    *)
        claude -r || claude
        ;;
esac
