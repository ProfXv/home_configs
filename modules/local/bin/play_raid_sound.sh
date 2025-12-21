#!/bin/sh

nohup ffplay "$(shuf -en1 ~/Music/AirRaid2006/$1)" -nodisp -autoexit > /dev/null 2>&1 &
