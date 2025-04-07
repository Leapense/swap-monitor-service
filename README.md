# Swap Monitor Service

Swap Monitor Service is a Bash script that monitors swap memory usage and automatically clears swap when usage exceeds a user-defined threshold. The service uses Zenity for GUI notifications and configuration, making it accessible and user-friendly across various Linux distributions.

## Features

- **Automatic Monitoring:** Periodically checks swap memory usage.
- **Auto Cleanup:** Clears swap memory when usage exceeds the configured threshold.
- **GUI Notifications:** Uses Zenity to display alerts and configuration dialogs.
- **Password Prompt:** Uses a Zenity-based askpass helper for GUI sudo password entry.
- **Flexible Installation:** Supports both user-level (systemctl --user) and system-wide installations.
- **Multi-Distro Support:** Works on Fedora, Ubuntu, Debian, Arch Linux, and more.

## Prerequisites

- A Linux distribution with systemd and a graphical desktop environment.
- [Zenity](https://help.gnome.org/users/zenity/stable/) installed (the installer can automatically install it on supported distributions).
- Sudo privileges.
- For GUI sudo password prompts, the Zenity askpass helper script is required.

## Installation

### Using the Installer Script

An installer script is provided to simplify the installation process by automatically copying files, creating service files, and enabling the service.

1. **Clone the repository:**

    ```bash
    git clone https://github.com/YourUsername/swap-monitor-service.git
    cd swap-monitor-service
    ```

2. **Make scripts executable:**

    ```bash
    chmod +x swapMemMonitoring.sh swap_monitor_settings.sh install_swap_monitor.sh zenity_askpass.sh
    ```

3. **Update the askpass helper path:**

   Edit `swapMemMonitoring.sh` at the very top to export the `SUDO_ASKPASS` variable. For example, replace `/path/to/zenity_askpass.sh` with the full path to your `zenity_askpass.sh`:

    ```bash
    export SUDO_ASKPASS="/path/to/zenity_askpass.sh"
    ```

4. **Run the installer:**

    ```bash
    ./install_swap_monitor.sh
    ```

5. **Choose your installation mode when prompted:**

    - **User Install (Home Directory):** Installs the service for the current user using `systemctl --user`.
    - **System Install (System Directory):** Installs the service system-wide (requires sudo privileges).

The installer will copy the swap monitoring script to the appropriate directory, create a systemd service file, reload the daemon, and start the service automatically.

## Usage

Once installed, the Swap Monitor Service runs in the background, checking swap usage periodically. If the usage exceeds the configured threshold, the service clears the swap and displays a notification.

### Changing the Swap Cleanup Threshold

To change the threshold at which the swap is cleared, use the provided settings script:

```bash
./swap_monitor_settings.sh
```

This will open a Zenity dialog where you can set a new threshold between 40% and 70%. The new setting is saved to `~/.swap_monitor_config` and will be used by the monitoring script.

## Troubleshooting

- **GUI Not Displaying:**
  - If Zenity dialogs do not appear when running as a system-wide service, consider using a user-level service (`systemctl --user`), as it automatically inherits the desktop session's `DISPLAY` and `XAUTHORITY` variables.
  - Alternatively, ensure that your service file has the correct environment variables set for X access.

- **Sudo Password Prompt Issues:**
  - The script uses a Zenity askpass helper to display a GUI password prompt. Ensure that you have created `zenity_askpass.sh` and updated its path in `swapMemMonitoring.sh`.
  - If the prompt still fails, verify that the environment variable `SUDO_ASKPASS` is properly exported and that the script is executable.

- **Permission Issues:**
  - For system-wide installations, ensure that the service has the proper privileges and that any necessary X server permissions (e.g., via `xhost`) are configured.

- **Zenity Installation:**
  - The installer attempts to auto-install Zenity on supported distributions. If your distro is not supported, please install Zenity manually.

## Repository

For the complete source code and further documentation, please visit the [GitHub Repository](https://github.com/Leapense/swap-monitor-service).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

