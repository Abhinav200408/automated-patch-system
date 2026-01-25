# Client-Server Setup Guide

This guide explains how to set up the **Automated Patch Management System** with one machine as the **Server** and another as the **Client**.

## 1. Server Setup (This Machine)

You are currently on the **Server**.

1.  **Start the Server**:
    *   Double-click `start_system.bat` in the `d:\automated_patch_system` folder.
    *   This will start the web dashboard and the API server.
    *   Keep this window open.

2.  **Find Your Server IP**:
    *   Your Server IP address is: **172.22.205.250**
    *   (You can also find this by running `ipconfig` in a terminal and looking for "IPv4 Address").

## 2. Client Setup (The Other Machine)

On the **Client** computer (the one you want to control):

1.  **Copy Files**: Copy the following files from the Server (`d:\automated_patch_system`) to the Client computer (e.g., using a USB drive or network share):
    *   `setup_client.bat`
    *   `install_python.bat`
    *   `client_startup.bat`
    *   The `agent` folder (and all its contents)
    *   **IMPORTANT**: Do **NOT** copy the `venv` folder. It will break on the client.

2.  **Run Setup**:
    *   Double-click `setup_client.bat` on the Client.
    *   **Python**: It will automatically launch `install_python.bat` if Python is missing (installs to local folder).
    *   **Dependencies**: Pre-bundled (no internet needed for libraries).
    *   **Configuration**:
        *   It will ask for the **Server IP Address** (e.g., `172.22.205.250`).
        *   Enter the IP and press Enter.
    *   **Auto-Start**: The script will automatically add itself to the Startup folder. The agent will run every time the computer turns on.

3.  **Success**: The agent will start and connect to the server.
    *   Go back to the **Server Dashboard** (http://localhost:5000).
    *   You should see the new agent appear in the "Remote Fleet" list.
    *   Click on the agent name to **Control it Remotely** (Install updates, check logs, etc.).

## Troubleshooting

*   **Firewall**: Ensure Windows Firewall allows traffic on ports **5000** (Dashboard) and **5001** (API) on the Server.
*   **Network**: Both computers must be on the same network (e.g., connected to the same Wi-Fi or Router).
