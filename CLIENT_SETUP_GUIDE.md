# Client-Server Setup Guide

This guide explains how to set up the **Automated Patch Management System** with one machine as the **Server** and another as the **Client**.

*   **Network**: Both computers must be on the same network (e.g., connected to the same Wi-Fi or Router).
    *   **Configuration**:
        *   It will ask for the **Server IP Address** (e.g., `172.22.205.250`).
        *   Enter the IP and press Enter.
    *   **Auto-Start**: The script will automatically add itself to the Startup folder. The agent will run every time the computer turns on.

3.  **Success**: The agent will start and connect to the server.
    *   Go back to the **Server Dashboard** (http://localhost:5000).
    *   You should see the new agent appear in the "Remote Fleet" list.
    *   Click on the agent name to **Control it Remotely** (Install updates, check logs, etc.).
