#!/bin/bash

workspace_id=$(hyprctl activeworkspace -j | jq .id)
workspace_name=$(hyprctl activeworkspace -j | jq -r .name)
[ -z `echo $workspace_id | grep -` ] && [ "$workspace_id" != "$workspace_name" ] &&
path=~/Desktop/Projects/ours/$workspace_name || path=~ && mkdir -p "$path/$1" && cd "$path/$1"
