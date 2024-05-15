#!/bin/sh

if [[ -e /tmp/toggle_state ]]; then
    if [[ "$(swaymsg -t get_workspaces | jq '.[] | select(.name == "back_and_forth").nodes | length')" -eq 0 ]]; then
        swaymsg move container to workspace number 5; swaymsg workspace number 5
        rm /tmp/toggle_state
    fi
else
    if [[ "$(swaymsg -t get_workspaces | jq '.[] | select(.name == "back_and_forth").nodes | length')" -eq 0 ]]; then
        swaymsg move container to workspace back_and_forth; swaymsg workspace back_and_forth
        touch /tmp/toggle_state
    fi
fi
