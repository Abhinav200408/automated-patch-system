# Automated Patch Management System

A centralized dashboard to manage Windows updates and third-party software across your network.

## Features
- **Central Dashboard**: View all connected agents, their status, and system info.
- **Windows Updates**: Check for, download, and install Windows updates remotely.
- **Third-Party Updates**: Manage software updates using `winget`.
- **Real-time Status**: Live feedback on command execution.

## Setup (Server)
1.  Install Python 3.8+.
2.  Install dependencies: `pip install -r requirements.txt`.
3.  Run `start_system.bat`.
4.  Access dashboard at `http://localhost:5001`.

## Network Deployment (Connecting Other Devices)
To manage other computers on your network:

1.  **On the Server (Main PC):**
    *   Run `start_system.bat`.
    *   Find your IP address (open CMD and type `ipconfig`). It will be something like `192.168.1.X`.

2.  **On the Client (Remote PC):**
    *   Copy the `agent` folder and `requirements.txt` to the remote PC.
    *   Install Python and dependencies: `pip install -r requirements.txt`.
    *   Create a file named `config.json` in the same folder as `agent.py` with the following content:
        ```json
        {
            "server_url": "http://YOUR_SERVER_IP:5001"
        }
        ```
        (Replace `YOUR_SERVER_IP` with the IP from Step 1).
    *   Run the agent: `python agent.py` (Run as Administrator for patching features).

The new agent will appear on your dashboard automatically.
