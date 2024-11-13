#!/bin/bash

unicode=`kitten unicode-input`
hyprctl dispatch focuscurrentorlast
wtype $unicode
