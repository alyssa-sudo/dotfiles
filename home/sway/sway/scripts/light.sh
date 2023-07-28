#!/bin/bash

# Function to execute a command and capture its output
execute_command() {
    local output=$(eval "$1")
    echo "$output"
}

# Function to display a notification with a moving bar
display_notification() {
    local brightness=$1
    local bar_length=$(echo "$brightness / 10" | bc)
    local bar="[$(yes "#" | head -n "$bar_length" | tr -d '\n'; yes "-" | head -n "$((10 - bar_length))" | tr -d '\n')]"
    local title="Brightness"
    local message="$(printf "%.0f%% %s" "$brightness" "$bar")"
    notify-send --app-name "brightness" -u normal -t 2000 -i display-brightness-symbolic "$title" "$message" -a "brightness-notification"
}

if [[ $# -lt 1 ]]; then
    echo "Usage: bash script.sh <up/down>"
    exit 1
fi

action=$1

if [[ $action == "up" ]]; then
    # Increase the brightness
    execute_command "xbacklight -inc 5"
elif [[ $action == "down" ]]; then
    # Decrease the brightness
    execute_command "xbacklight -dec 5"
else
    echo "Invalid action. Usage: bash script.sh <up/down>"
    exit 1
fi

# Get the new brightness level and display the updated notification if the previous one is not active
brightness=$(execute_command "light | awk '{print int(\$1)}'")
notification_active=$(execute_command "pgrep -f \"notify-send.*brightness-notification\"")

if [[ -z "$notification_active" ]]; then
    display_notification "$brightness"
fi

