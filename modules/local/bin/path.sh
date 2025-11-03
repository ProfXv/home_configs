#!/bin/sh

path=~
workspace_id=$(hyprctl activeworkspace -j | jq .id)
workspace_name=$(hyprctl activeworkspace -j | jq -r .name)
echo $workspace_id | grep -v - && [ "$workspace_id" != "$workspace_name" ] &&
path=~/Desktop/Projects/$workspace_name && cd "$path"
export PROJECT_HOME=$path
