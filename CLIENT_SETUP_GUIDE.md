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

1.  **Get the Code**:
    *   Clone the repository:
        ```bash
        git clone https://github.com/Abhinav200408/automated-patch-system.git
        ```
    *   Or copy the entire `automated_patch_system` folder from the server to the client.

2.  **Run the Setup Script**:
    *   Open the folder on the client machine.
    *   Right-click **`setup_client.bat`** and select **Run as Administrator** (or just double-click, it will ask for permission).
    *   **Automation**: The script will automatically install Python and necessary libraries if they are missing.

3.  **Enter Server IP**:
    *   The script will ask for the **Server IP**.
    *   Enter the IP address from Step 1 (e.g., `192.168.1.X`).

4.  **Verify Connection**:
    *   The agent will start and attempt to register with the server.
    *   Go back to the **Server Dashboard** (http://localhost:5000).
    *   You should see the new agent appear in the "Agents" list.

## Troubleshooting

*   **Firewall**: Ensure Windows Firewall allows traffic on ports **5000** (Dashboard) and **5001** (API) on the Server.
*   **Network**: Both computers must be on the same network (e.g., connected to the same Wi-Fi or Router).
