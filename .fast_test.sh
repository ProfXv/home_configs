#!/bin/bash

path=/tmp/scripts
mkdir -p $path
xclip -o > $path/$1
kitty --hold $1 $path/$1
