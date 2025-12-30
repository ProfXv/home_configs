#!/bin/sh

AUTO="--permission-mode acceptEdits"
BETA="--betas interleaved-thinking"
case "$PROJECT_HOME" in
    $HOME/Desktop/Projects/*)
        claude -r $AUTO $BETA || claude $AUTO $BETA
        ;;
    *)
        claude -r $BETA || claude $BETA
        ;;
esac
