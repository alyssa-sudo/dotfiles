#!/usr/bin/env lua
local notification_file = "/tmp/volume_notification_id"
local action = arg[1]

-- Function to display a notification with a moving bar
function display_notification(volume, notification_id)
    local bar_length = math.floor(volume / 10)
    local bar = "[" .. string.rep("#", bar_length) .. string.rep("-", 10 - bar_length) .. "]"
    local title = "Volume"
    local message = string.format("%d%% %s", math.floor(volume), bar)
    os.execute(string.format("notify-send -u normal -i notification-audio-volume-medium -h int:value:%d -h string:synchronous:volume -h string:x-canonical-private-synchronous:volume '%s' '%s'", volume, title, message))
end

-- Function to display a "volume muted" notification
function display_muted_notification(notification_id)
    local title = "Volume"
    local message = "Muted"
    os.execute(string.format("notify-send -u normal -i notification-audio-volume-muted -h string:synchronous:volume -h string:x-canonical-private-synchronous:volume '%s' '%s'", title, message))
end

-- Function to display a "mic muted" notification
function display_mic_muted_notification(notification_id)
    local title = "Mic"
    local message = "Muted"
    os.execute(string.format("notify-send -u normal -i microphone-sensitivity-muted -h string:synchronous:mic -h string:x-canonical-private-synchronous:mic '%s' '%s'", title, message))
end

-- Function to display a "mic unmuted" notification
function display_mic_unmuted_notification(notification_id)
    local title = "Mic"
    local message = "Unmuted"
    os.execute(string.format("notify-send -u normal -i microphone-sensitivity-high -h string:synchronous:mic -h string:x-canonical-private-synchronous:mic '%s' '%s'", title, message))
end

-- Read the notification ID from the file if it exists
local notification_id
local file = io.open(notification_file, "r")
if file then
    notification_id = file:read("*all")
    file:close()
end

if action == "up" then
    -- Increase the volume
    os.execute("amixer -q -D pipewire sset Master 5%+")
elseif action == "down" then
    -- Decrease the volume
    os.execute("amixer -q -D pipewire sset Master 5%-")
elseif action == "mute" then
    -- Toggle the volume mute state
    os.execute("amixer -q -D pipewire sset Master toggle")
elseif action == "mic_mute" then
    -- Toggle the microphone mute state
    os.execute("amixer -q -D pipewire sset Capture toggle")
end

-- Get the new volume level and update the notification
local handle = io.popen("amixer -D pipewire sget Master")
local output = handle:read("*a")
handle:close()
local volume = tonumber(string.match(output, "(%d+)%%"))

-- Get the volume mute state and update the notification
handle = io.popen("amixer -D pipewire sget Master")
output = handle:read("*a")
handle:close()
local volume_mute_state = string.match(output, "%[(o[^%]]*)%]")

-- Get the microphone mute state and update the notification
handle = io.popen("amixer -D pipewire sget Capture")
output = handle:read("*a")
handle:close()
local mic_mute_state = string.match(output, "%[(o[^%]]*)%]")

if volume then
    if action == "mute" then
        if volume_mute_state == "off" then
            display_muted_notification(notification_id)
        else
            display_notification(volume, notification_id)
        end
    elseif action == "mic_mute" then
        if mic_mute_state == "off" then
            display_mic_muted_notification(notification_id)
        else
            display_mic_unmuted_notification(notification_id)
        end
    else
        if volume_mute_state == "off" then
            display_muted_notification(notification_id)
        else
            if notification_id then
                display_notification(volume, notification_id)
            else
                -- Generate a unique notification ID using the current time
                notification_id = os.time()
                display_notification(volume, notification_id)
            end
        end
    end

    -- Save the notification ID to the file
    file = io.open(notification_file, "w")
    if file then
        file:write(notification_id)
        file:close()
    end
else
    print("Failed to retrieve the volume level.")
    os.exit(1)
end
