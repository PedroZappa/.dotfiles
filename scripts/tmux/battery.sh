#!/usr/bin/env bash

# Battery segment for the tmux status bar.
# Prints "│ 󰁹 NN% " when a battery is detected, and prints nothing
# at all when there isn't one, so the whole segment disappears
# (e.g. on a desktop machine). Colors come from status-right-style.

pct=""

case "$(uname -s)" in
    Darwin)
        pct="$(pmset -g batt | grep -oE '[0-9]+%' | tr -d '%')"
        ;;
    Linux)
        for bat in /sys/class/power_supply/BAT*; do
            if [[ -f "$bat/capacity" ]]; then
                pct="$(<"$bat/capacity")"
                break
            fi
        done
        ;;
esac

# Only emit the separator + icon + value when a battery was found
[[ -n "$pct" ]] && printf ' 󰁹 %d%% ' "$pct"
