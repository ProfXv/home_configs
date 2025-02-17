#!/bin/bash

path=~/ORIGINAL
workspace_id=$(hyprctl activeworkspace -j | jq .id)
workspace_name=$(hyprctl activeworkspace -j | jq -r .name)
echo $workspace_id | grep -v - && [ "$workspace_id" != "$workspace_name" ] &&
path=$path/Desktop/Projects/ours/$workspace_name && mkdir -p "$path" && cd "$path"
export PROJECT_HOME=$path
