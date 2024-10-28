#!/bin/bash

cd "`~/.path.sh`"

action=$1
area=$2
case $action in
    "capture")
        mkdir -p Pictures
        case $area in
            "full")
                grim Pictures/`date +"%s.png"`
                ;;
            "select")
                grim -g "`slurp`" Pictures/`date +"%s.png"`
                ;;
        esac
        ;;
    "record")
        mkdir -p Videos
        case $area in
            "full")
                pkill wf-recorder || wf-recorder -f Videos/`date +"%s.mp4"`
                ;;
            "select")
                pkill wf-recorder || wf-recorder -g "`slurp`" -f Videos/`date +"%s.mp4"`
                ;;
        esac
        ;;
esac
