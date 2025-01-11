#!/bin/bash

workspace_id=$(hyprctl activeworkspace -j | jq .id)
workspace_name=$(hyprctl activeworkspace -j | jq -r .name)
echo $workspace_id | grep -v - && [ "$workspace_id" != "$workspace_name" ] &&
path=~/Desktop/Projects/ours/$workspace_name && mkdir -p "$path" && cd "$path" || path=~
export PROJECT_HOME=$path
