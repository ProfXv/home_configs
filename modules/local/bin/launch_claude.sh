#!/bin/sh

SKIP=--dangerously-skip-permissions
if [ "$PROJECT_HOME" = "$HOME" ]; then
    claude -r || claude
else
    agent_playground.sh -C -c "claude -r $SKIP || claude $SKIP"
fi
