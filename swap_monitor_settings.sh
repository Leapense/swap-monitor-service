#!/bin/bash
# swap_monitor_settings.sh - Script to update the swap cleaning threshold

CONFIG_FILE="$HOME/.swap_monitor_config"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    zenity --error --text="Configuration file not found. Please install the service first."
    exit 1
fi

# Load the current configuration (assumes SWAP_THRESHOLD is stored in the config file)
source "$CONFIG_FILE"
CURRENT_THRESHOLD=${SWAP_THRESHOLD:-50}  # Default to 50 if not set

# Use Zenity to get a new threshold value from the user
NEW_THRESHOLD=$(zenity --scale \
    --text="Current swap cleaning threshold is ${CURRENT_THRESHOLD}%.\nPlease set a new threshold (40-70):" \
    --min-value=40 --max-value=70 --value="${CURRENT_THRESHOLD}" --step=1)

# If the user cancels, exit without making changes
if [ $? -ne 0 ]; then
    zenity --info --text="No changes were made to the settings."
    exit 0
fi

# Save the new threshold value in the configuration file
echo "SWAP_THRESHOLD=$NEW_THRESHOLD" > "$CONFIG_FILE"
zenity --info --text="The new threshold has been saved as ${NEW_THRESHOLD}%."

exit 0

