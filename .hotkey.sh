#!/bin/bash

echo -e "$(date +%s)\t$1\t$2" >> ~/.hotkey_log
i3-msg "$2"
