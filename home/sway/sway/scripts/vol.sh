#!/bin/bash

notification_file="/tmp/volume_notification_id"
action=$1

# Function to display a notification with a moving bar
display_notification() {
    local volume=$1
    local bar_length=$((volume / 10))
    local bar="[$(printf '#%.0s' $(seq 1 "$bar_length"))$(printf '-%.0s' $(seq 1 $((10 - bar_length))))]"
    local title="Volume"
    local message="$((volume))% $bar"
    notify-send -u normal -i notification-audio-volume-medium -h "int:value:${volume}" -h "string:synchronous:volume" -h "string:x-canonical-private-synchronous:volume" "$title" "$message"
}

# Function to display a "volume muted" notification
display_muted_notification() {
    local title="Volume"
    local message="Muted"
    notify-send -u normal -i notification-audio-volume-muted -h "string:synchronous:volume" -h "string:x-canonical-private-synchronous:volume" -h "string:summary:Volume Muted" "$title" "$message"
}

# Function to display a "mic muted" notification
display_mic_muted_notification() {
    local title="Mic"
    local message="Muted"
    notify-send -u normal -i microphone-sensitivity-muted -h "string:synchronous:mic" -h "string:x-canonical-private-synchronous:mic" -h "string:summary:Mic Muted" "$title" "$message"
}

# Function to display a "mic unmuted" notification
display_mic_unmuted_notification() {
    local title="Mic"
    local message="Unmuted"
    notify-send -u normal -i microphone-sensitivity-high -h "string:synchronous:mic" -h "string:x-canonical-private-synchronous:mic" "$title" "$message"
}

# Read the notification ID from the file if it exists
notification_id=$(cat "$notification_file" 2>/dev/null)

if [ "$action" == "up" ]; then
    # Increase the volume
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
elif [ "$action" == "down" ]; then
    # Decrease the volume
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
elif [ "$action" == "mute" ]; then
    # Toggle the volume mute state
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
elif [ "$action" == "mic_mute" ]; then
    # Toggle the microphone mute state
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
fi

# Get the new volume level and update the notification
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume=$(echo "$output" | awk -F': ' '{print $2}')
volume=$(echo "$volume * 100" | bc)

# Get the volume mute state and update the notification
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume_mute_state=$(echo "$output" | awk -F"[][]" '/%/ { print $4 }')

# Get the microphone mute state and update the notification
output=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
mic_mute_state=$(echo "$output" | awk -F"[][]" '/%/ { print $4 }')

if [ -n "$volume" ]; then
    if [ "$action" == "mute" ]; then
        if [ "$volume_mute_state" == "off" ]; then
            display_muted_notification "$notification_id"
        else
            display_notification "$volume" "$notification_id"
        fi
    elif [ "$action" == "mic_mute" ]; then
        if [ "$mic_mute_state" == "off" ]; then
            display_mic_muted_notification "$notification_id"
        else
            display_mic_unmuted_notification "$notification_id"
        fi
    else
        if [ "$volume_mute_state" == "off" ]; then
            display_muted_notification "$notification_id"
        else
            if [ -n "$notification_id" ]; then
                display_notification "$volume" "$notification_id"
            else
                # Generate a unique notification ID using the current time
                notification_id=$(date +%s)
                display_notification "$volume" "$notification_id"
            fi
        fi
    fi

    # Save the notification ID to the file
    echo "$notification_id" > "$notification_file"
else
    echo "Failed to retrieve the volume level."
    exit 1
fi

