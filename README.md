# ASL3 ID

This Bash script monitors the keyed state of an **AllStarLink3 (ASL3)** node and provides audio notifications based on transmission activity. It is designed to run as a background service via `systemd`.

## Features

- **Initial ID**: Plays a sound immediately when the node transitions from Idle to Active.
- **Interval ID**: Plays a sound every 10 minutes if the node remains continuously active.
- **Idle ID**: Plays a sound exactly 2 minutes after the node returns to an idle state.
- **Automatic Recovery**: Configured to restart automatically if the process or Asterisk service fluctuates.

## Prerequisites

1.  **ASL3 Installed**: Designed for AllStarLink3 environments using `asterisk -rx`.
2.  **Audio File**: A compatible Asterisk audio file (e.g., `.ulaw`, `.gsm`, or `.pcm`) located in `/var/lib/asterisk/sounds/`.
3.  **Permissions**: Root or sudo access to create system services.

## Installation

### 1. Script Setup
1.  Copy `node_monitor.sh` to `/usr/local/bin/`.
2.  Edit the script to set your **Node Number** and **Sound File** path:
    ```bash
    NODE="1234"  # Your node number
    SOUND_FILE="/usr/share/asterisk/sounds/en/your_alert_file" # No extension
    ```
3.  Make the script executable:
    ```bash
    sudo chmod +x /usr/local/bin/node_monitor.sh
    ```

### 2. Service Configuration
1.  Create the service file:
    ```bash
    sudo nano /etc/systemd/system/asl-monitor.service
    ```
2.  Paste the following configuration:
    ```ini
    [Unit]
    Description=ASL3 Node Keyed State Monitor
    After=asterisk.service

    [Service]
    Type=simple
    Restart=always
    RestartSec=5
    ExecStart=/usr/local/bin/node_monitor.sh

    [Install]
    WantedBy=multi-user.target
    ```
3.  Reload and start the service:
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable asl-monitor.service
    sudo systemctl start asl-monitor.service
    ```

## Management & Troubleshooting

- **Check Status**: 
  `sudo systemctl status asl-monitor.service`
- **View Live Logs**: 
  `journalctl -u asl-monitor.service -f`
- **Stop Service**: 
  `sudo systemctl stop asl-monitor.service`

## Configuration Constants
Inside the script, you can adjust the following timers:
- `INTERVAL_SEC`: Frequency of alerts during long transmissions (Default: 600s / 10m).
- `IDLE_DELAY_SEC`: Wait time before the final "Idle" alert (Default: 120s / 2m).
