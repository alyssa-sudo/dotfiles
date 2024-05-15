#!/bin/bash

notify-send "Discpline on" "Will now close distractions."

while true
do

# Check if the PID file exists
pid_file="/tmp/script_pid_file"
if [ -e "$pid_file" ]; then
    # Check if the process with the PID is still running
    pid=$(cat "$pid_file")
    if ps -p "$pid" > /dev/null; then
        echo "Script is already running with PID $pid. Exiting."
        exit 1
    else
        # Clean up stale PID file
        rm -f "$pid_file"
    fi
fi

# Function to clean up and exit
cleanup_and_exit() {
    rm -f "$pid_file"
    exit
}

# Trap signals to ensure cleanup before exiting
trap 'cleanup_and_exit' EXIT

# Create the PID file
echo "$$" > "$pid_file"

# Close applications on launch that are unneeded.
improper_apps=("Discord" "Steam")

# Specify the improper domains you want to monitor
improper_domains=("youtube.com" "github.com" "stackoverflow.com")

# Variable to track the last improper domain
last_improper_domain=""

while true
do
    # Check and close applications
    for app in "${improper_apps[@]}"
    do
        # Check if the application is running using pgrep
        if pgrep -f "$app" > /dev/null
        then
            # Debug output
            echo "Found $app running. Attempting to close..."

            # Close the application and show a notification
            pkill -f "$app" && notify-send "$app closed" "Get to work."
            
            # Debug output
            echo "$app closed successfully."
        else
            # Debug output
            echo "$app is not running."
        fi
    done

    # Check and close Chrome based on improper domains
    if pgrep -x "chrome" > /dev/null
    then
        # Get the currently focused window's title
        current_title=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')

        # Extract the page title from the title (assumes title format "Page Title - Google Chrome")
        page_title=$(echo "$current_title" | sed -n 's/ - Google Chrome$//p')

        # Extract the domain from the page title
        domain=$(echo "$page_title" | awk -F ' - ' '{print $NF}')

        # Debug output
        echo "Original Domain: $domain"

        # Convert to lowercase, remove spaces, and add ".com"
        normalized_domain=$(echo "$domain" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/$/.com/')

        # Debug output
        echo "Normalized Domain: $normalized_domain"

        # Check if the normalized domain is in the list of improper domains
        for improper_domain in "${improper_domains[@]}"
        do
            if [[ "$normalized_domain" == *"$improper_domain"* ]]
            then
                # Give a 5-second warning
                for i in {5..1}
                do
                    # Check if the focused window remains the same
                    new_title=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')
                    if [[ "$new_title" != "$current_title" ]]
                    then
                        echo "Page changed. Canceling." && notify-send "Page changed." "Canceling."
                        break
                    fi

                    echo "Warning: Closing Chrome in $i seconds..." && notify-send "Warning:" "Closing Chrome in $i seconds..."
                    sleep 1
                done

                # Check if the focused window is still the same after the warning
                final_title=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')
                if [[ "$final_title" == "$current_title" ]]
                then
                    # Close Chrome if an improper domain is detected and the page is not changed
                    pkill chrome && echo "Chrome closed." && notify-send "Chrome closed."
                fi

                # Update the last improper domain
                last_improper_domain="$normalized_domain"
            elif [[ -z "$normalized_domain" && -n "$last_improper_domain" ]]
            then
                # If the current domain is empty, retain the last improper domain and close Chrome
                pkill chrome && echo "Chrome closed. Last improper domain retained: $last_improper_domain." && notify-send "Chrome closed." "Last improper domain retained: $last_improper_domain."
            fi
        done
    else
        echo "Chrome is not running."
    fi

    # Sleep for 5 seconds before checking again
    sleep 5
done
done
