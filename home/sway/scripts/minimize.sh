#!/bin/sh

if [ -e /tmp/toggle_state ]; then
	swaymsg move scratchpad
    rm /tmp/toggle_state
else
	swaymsg scratchpad show; swaymsg floating disable
    touch /tmp/toggle_state
fi
