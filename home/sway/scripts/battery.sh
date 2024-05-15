#!/bin/sh

check_battery_status() {
    local prev_status=""
    while true; do
        status=$(cat /sys/class/power_supply/BAT0/status)
        if [ "$status" != "$prev_status" ]; then
            case "$status" in
                "Charging")
                    notify-send "Battery status:" "Charging"
                    ;;
                "Discharging")
                    notify-send "Battery status:" "Discharging"
                    ;;
                "Not charging")
                    notify-send "Battery status:" "Full, not charging"
                    ;;
                "Full")
                    notify-send "Battery status:" "Battery is full"
                    ;;
            esac
            prev_status="$status"
        fi
    done
}

check_battery_status &  # Run the function in the background
disown  # Disown the background job to detach it from the terminal
