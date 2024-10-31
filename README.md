# Kiosk Mode Configuration Script for Debian 12 and XFCE

This configuration script transforms a Debian 12 machine into a passive kiosk mode. The kiosk mode is designed to automatically launch Chromium in fullscreen mode, displaying a specified webpage (`https://yourwebpage.com`) when the computer starts, without requiring user login. This mode is ideal for showcasing dashboards, presentations, or static web pages on a display.

## Features

1. **Automatic Kiosk Startup**: Chromium opens in kiosk mode and displays the page `https://yourwebpage.com` as soon as the system boots up.
2. **Monitoring and Refreshing**: A watchdog script checks every 30 minutes whether Chromium is running. If necessary, it restarts Chromium or refreshes the current page.
3. **Keyboard Shortcut to Exit Kiosk**: A keyboard shortcut (`Ctrl + Alt + Delete`) allows the user to stop the kiosk mode, providing access to the login window or desktop environment.

## Prerequisites

- **Debian 12**: Ensure you are running Debian 12 or a compatible distribution.
- **Internet Connection**: The script requires an internet connection to install necessary packages and to access the specified webpage.

## Dependencies

The script automatically installs the following packages if they are not already installed:
- `chromium`: The web browser used in kiosk mode.
- `xdotool`: A tool to simulate keyboard input and mouse activity.
- `xmlstarlet`: A command-line XML toolkit used to modify XFCE keyboard shortcuts.

## Installation and Usage

1. **Download the Script**: Save the script as `setup_kiosk.sh`.

2. **Make the Script Executable**:
   ```bash
   chmod +x setup_kiosk.sh
   ```

3. **Run the Script with Superuser Privileges**:
   ```bash
   sudo ./setup_kiosk.sh
   ```

4. **Reboot Your Computer**: After executing the script, restart your computer to apply the changes.

## Script Workflow

1. **Install Dependencies**: The script updates the package list and installs Chromium, `xdotool`, and `xmlstarlet`.
2. **Create Kiosk Launch Script**: It creates a script to launch Chromium in kiosk mode with the specified URL.
3. **Set Up Systemd Service**: A systemd service is created to ensure Chromium starts automatically at boot.
4. **Create Watchdog Script**: A script is set up to monitor the running state of Chromium and refresh or restart it as needed.
5. **Add Cron Job**: A cron job is added to run the watchdog script every 30 minutes.
6. **Configure XFCE Keyboard Shortcut**: The script automatically configures a keyboard shortcut to stop the kiosk service, allowing easy access to the system.

## Detailed Explanation of System Changes and Post-Installation Parameter Adjustments

The kiosk mode configuration script performs several actions on your Debian 12 system to set up a kiosk environment effectively. Here’s a detailed breakdown of each change made by the script, along with instructions on how to modify parameters post-installation if your needs change.

---

### System Changes Made by the Script

1. **Installation of Dependencies**:
   - **Packages Installed**: 
     - **Chromium**: The browser used to display the specified webpage in kiosk mode.
     - **xdotool**: A utility that simulates keyboard input and mouse actions, used to refresh the webpage.
     - **xmlstarlet**: A command-line tool for parsing and editing XML, utilized to manage keyboard shortcuts.
   - **How to Change**: If you need a different browser (e.g., Firefox), you can manually install it later and modify the kiosk launch script path.

2. **Creation of the Kiosk Launch Script**:
   - **File Path**: The script is created at `/usr/local/bin/kiosk.sh`.
   - **Content**: The script contains commands to launch Chromium in kiosk mode with the specified URL.
   - **How to Change**: 
     - To update the URL displayed, edit the `kiosk.sh` file:
       ```bash
       sudo nano /usr/local/bin/kiosk.sh
       ```
     - Change the URL in the line:
       ```bash
       /usr/bin/chromium --noerrdialogs --disable-infobars --kiosk "https://yourwebpage.com"
       ```
     - Save and exit (CTRL + X, then Y, then Enter).

3. **Systemd Service Creation**:
   - **Service File Path**: A systemd service file is created at `/etc/systemd/system/kiosk.service`.
   - **Functionality**: This service manages the kiosk mode, ensuring Chromium starts automatically on boot.
   - **How to Change**:
     - If you want to modify the service parameters (like environment variables), edit the service file:
       ```bash
       sudo nano /etc/systemd/system/kiosk.service
       ```
     - After making changes, remember to reload the systemd configuration:
       ```bash
       sudo systemctl daemon-reload
       ```
     - You can restart the service using:
       ```bash
       sudo systemctl restart kiosk.service
       ```

4. **Creation of the Watchdog Script**:
   - **File Path**: The watchdog script is created at `$HOME/chromium_cron_watchdog.sh`.
   - **Functionality**: This script checks if Chromium is running every 30 minutes and refreshes or restarts it if necessary.
   - **How to Change**:
     - You can adjust the interval for the cron job. Open the crontab:
       ```bash
       crontab -e
       ```
     - Change the line that runs the watchdog script to adjust the frequency (e.g., `*/15 * * * *` for every 15 minutes).

5. **Cron Job Addition**:
   - **Job Schedule**: The script adds a cron job that executes the watchdog script every 30 minutes.
   - **How to Change**: 
     - You can modify this schedule in the crontab as mentioned above. To remove the job, delete the corresponding line in the crontab.

6. **XFCE Keyboard Shortcut Configuration**:
   - **File Path**: The keyboard shortcut configuration is saved in `$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`.
   - **Functionality**: The shortcut `Ctrl + Alt + Delete` is set to stop the kiosk service.
   - **How to Change**: 
     - To add or modify keyboard shortcuts, you can use the XFCE GUI by navigating to:
       - **Settings > Keyboard > Application Shortcuts**.
     - Alternatively, you can directly edit the XML file:
       ```bash
       nano "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
       ```

### Post-Installation Adjustments

If your requirements change after installing the script, here are some common adjustments you might want to make:

- **Changing the Displayed URL**:
  Edit the kiosk launch script as described above to point to a new URL.

- **Modifying the Refresh Interval**:
  Update the cron job frequency in the crontab.

- **Adding New Keyboard Shortcuts**:
  Use the XFCE GUI or modify the XML file directly to add or change shortcuts.

- **Changing Browser Settings**:
  If you switch browsers, update the kiosk launch script with the new browser path and options.

- **Stopping/Starting the Kiosk Mode**:
  You can stop the kiosk service anytime using:
  ```bash
  sudo systemctl stop kiosk.service
  ```
  To start it again:
  ```bash
  sudo systemctl start kiosk.service
  ```


