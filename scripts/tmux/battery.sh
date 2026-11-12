#!/usr/bin/env bash

# Battery segment for the tmux status bar.
# Prints "│ 󰁀/󰁂/󰁁 NN% " when a battery is detected, and prints nothing
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

# Only emit the separator + icon + value when a battery was found.
# Icon follows the charge level:
#   <=20% 󰁀 (nf-fa-battery_empty)  <=50% 󰁂 (nf-fa-battery_half)  else 󰁁 (nf-fa-battery_full)
# The icon turns red at 20% or below; #[default] restores the status
# bar's own color for the rest of the segment.
if [[ -n "$pct" ]]; then
    pct="${pct//[!0-9]/}"
    if (( pct <= 10 )); then
        printf '#[fg=red] 󰁺 #[default]%d%% ' "$pct"
    elif (( pct <= 20 )); then
        printf '#[fg=red] 󰁻 #[default]%d%% ' "$pct"
    elif (( pct <= 30 )); then
        printf ' 󰁼 %d%% ' "$pct"
    elif (( pct <= 40 )); then
        printf ' 󰁽 %d%% ' "$pct"
    elif (( pct <= 50 )); then
        printf ' 󰁾 %d%% ' "$pct"
    elif (( pct <= 60 )); then
        printf ' 󰁿 %d%% ' "$pct"
    elif (( pct <= 70 )); then
        printf ' 󰂀 %d%% ' "$pct"
    elif (( pct <= 80 )); then
        printf ' 󰂁 %d%% ' "$pct"
    elif (( pct <= 90 )); then
        printf ' 󰂂 %d%% ' "$pct"
    else
        printf ' 󰁹 %d%% ' "$pct"
    fi
fi
