#!/bin/bash

path=/tmp/scripts
mkdir -p $path
wl-paste -p > $path/$1
kitty --hold $1 $path/$1
