#!/bin/bash
CORES="$(sysctl -n hw.ncpu)"
CPU="$(ps -A -o %cpu= | awk -v c="$CORES" '{s+=$1} END {printf "%d", s/c}')"
sketchybar --set "$NAME" label="${CPU}%"
