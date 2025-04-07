#!/bin/bash

# Set SUDO_ASKPASS for sudo -A to work with a Zenity GUI prompt
export SUDO_ASKPASS="/path/to/zenity_askpass.sh"

# If DISPLAY is not set, assign default values
if [ -z "$DISPLAY" ]; then
    echo "DISPLAY variable not found. Setting DISPLAY to :0"
    export DISPLAY=:0
fi

if [ -z "$XAUTHORITY" ]; then
    echo "XAUTHORITY variable not found. Setting XAUTHORITY to \$HOME/.Xauthority"
    export XAUTHORITY="$HOME/.Xauthority"
fi

# Set GUI usage flag
if [ -n "$DISPLAY" ]; then
    USE_GUI=true
else
    USE_GUI=false
fi

# Get distribution info
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID
else
    distro="unknown"
fi

# Check if Zenity is installed and install it if necessary (GUI mode)
if ! command -v zenity &>/dev/null; then
    if [ "$USE_GUI" = true ]; then
        case "$distro" in
        fedora)
            echo "Installing zenity..."
            sudo dnf install -y zenity
            ;;
        ubuntu|debian)
            echo "Installing zenity..."
            sudo apt-get install -y zenity
            ;;
        arch)
            echo "Installing zenity..."
            sudo pacman -S --noconfirm zenity
            ;;
        *)
            echo "zenity not found. Please install it manually."
            exit 1
            ;;
        esac
    else
        echo "zenity not found and no GUI environment available. Please install zenity manually if needed."
        exit 1
    fi
fi

CONFIG_FILE="$HOME/.swap_monitor_config"

# If configuration file does not exist, get threshold via GUI or CLI
if [ ! -f "$CONFIG_FILE" ]; then
    if [ "$USE_GUI" = true ]; then
        THRESHOLD=$(zenity --scale --text="Please set the swap memory threshold (40-70): " --min-value=40 --max-value=70 --value=50 --step=1)
        if [ $? -ne 0 ]; then
            echo "Configuration canceled"
            exit 1
        fi
    else
        echo "Enter swap memory threshold (40-70): "
        read THRESHOLD
    fi
    echo "SWAP_THRESHOLD=$THRESHOLD" >"$CONFIG_FILE"
else
    source "$CONFIG_FILE"
fi

# The rest of your script remains the same...
# Main monitoring loop starts here
while true; do
    read -r total used <<<$(free | awk '/Swap/ {print $2, $3}')

    if [ "$total" -eq 0 ]; then
        if [ "$USE_GUI" = true ]; then
            zenity --error --text="Swap memory not found"
        else
            echo "Swap memory not found"
        fi
        exit 1
    fi

    usage_percent=$((100 * used / total))
    echo "Swap usage: ${usage_percent}%"

    if [ "$usage_percent" -ge "$SWAP_THRESHOLD" ]; then
        if [ "$USE_GUI" = true ]; then
            zenity --warning --text="WARNING: Swap usage is high (${SWAP_THRESHOLD}%)"
        else
            echo "WARNING: Swap usage is high (${SWAP_THRESHOLD}%)"
        fi
        sync
        echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

        if sudo -A swapoff -a; then
            sudo -A swapon -a
            if [ "$USE_GUI" = true ]; then
                zenity --info --text="$(date): Swap memory cleared"
            else
                echo "$(date): Swap memory cleared"
            fi
        else
            if [ "$USE_GUI" = true ]; then
                zenity --error --text="$(date): Failed to clear swap memory"
            else
                echo "$(date): Failed to clear swap memory"
            fi
        fi
    fi

    sleep 30
done

