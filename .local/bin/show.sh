#!/bin/bash

hyprctl activewindow -j > /tmp/info.json
less /tmp/info.json
