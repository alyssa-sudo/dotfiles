#!/usr/bin/env lua

-- Function to execute a command and capture its output
local function execute_command(command)
    local file = io.popen(command)
    local output = file:read("*a")
    file:close()
    return output
end

-- Function to display a Dunst notification with a moving bar
local function display_notification(brightness)
    local bar_length = math.floor(brightness / 10)
    local bar = "[" .. string.rep("#", bar_length) .. string.rep("-", 10 - bar_length) .. "]"
    local title = "Brightness"
    local message = string.format("%.0f%% %s", brightness, bar)
    execute_command("dunstify -r 1 -u normal '" .. title .. "' '" .. message .. "'")
end

if #arg < 1 then
    print("Usage: lua script.lua <up/down>")
    os.exit(1)
end

local action = arg[1]

if action == "up" then
    -- Increase the brightness
    execute_command("light -A 5")
elseif action == "down" then
    -- Decrease the brightness
    execute_command("light -U 5")
else
    print("Invalid action. Usage: lua script.lua <up/down>")
    os.exit(1)
end

-- Get the new brightness level and display the updated notification
local brightness = tonumber(execute_command("light"):match("(%d+%.?%d*)"))
display_notification(brightness)
