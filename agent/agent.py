import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'libs'))

import requests
import time
import json
import socket
import uuid
import os
from utils import (
    check_available_updates, install_updates, check_installed_software,
    list_installed_hotfixes, health_status, check_third_party_updates,
    install_third_party_updates, download_updates
)

# Configuration
# Configuration
CONFIG_FILE = "config.json"
DEFAULT_SERVER_URL = "http://127.0.0.1:5001"

def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading config: {e}")
            pass
    return {}

config = load_config()
SERVER_URL = config.get("server_url", DEFAULT_SERVER_URL)
AGENT_ID_FILE = "agent_id.txt"

def get_agent_id():
    if os.path.exists(AGENT_ID_FILE):
        with open(AGENT_ID_FILE, 'r') as f:
            return f.read().strip()
    new_id = str(uuid.uuid4())
    with open(AGENT_ID_FILE, 'w') as f:
        f.write(new_id)
    return new_id

AGENT_ID = get_agent_id()
HOSTNAME = socket.gethostname()
IP_ADDRESS = socket.gethostbyname(HOSTNAME)

def register():
    print(f"Registering agent {AGENT_ID}...")
    try:
        payload = {
            "id": AGENT_ID,
            "hostname": HOSTNAME,
            "ip_address": IP_ADDRESS
        }
        requests.post(f"{SERVER_URL}/api/register", json=payload)
        print("Registered successfully.")
    except Exception as e:
        print(f"Registration failed: {e}")

def heartbeat():
    try:
        payload = {"id": AGENT_ID}
        response = requests.post(f"{SERVER_URL}/api/heartbeat", json=payload)
        if response.status_code == 200:
            data = response.json()
            commands = data.get("commands", [])
            for cmd in commands:
                process_command(cmd)
    except Exception as e:
        print(f"Heartbeat failed: {e}")

def process_command(cmd_data):
    cmd_id = cmd_data['id']
    command = cmd_data['command']
    print(f"Received command: {command}")
    
    result = "Command executed."
    
    try:
        # Execute command
        if command == "check_updates":
            result = check_available_updates()
        elif command == "install_updates":
            success, msg = install_updates(ignore_reboot=True)
            result = msg
        elif command == "check_installed":
            result = check_installed_software()
        elif command == "list_hotfixes":
            result = list_installed_hotfixes()
        elif command == "get_log":
            try:
                with open('logs/patch_log.txt', 'r') as f:
                    result = f.read()
            except:
                result = "Log file not found."
        elif command == "check_third_party":
            result = check_third_party_updates()
        elif command == "install_third_party":
            success, msg = install_third_party_updates()
            result = msg
        elif command == "download_updates":
            success, msg = download_updates()
            result = msg
            
        print(f"Result length: {len(str(result))}")
    except Exception as e:
        result = f"Error executing command: {str(e)}"
        print(result)
    
    # Report completion
    try:
        requests.post(f"{SERVER_URL}/api/report", json={"command_id": cmd_id, "result": str(result)})
    except Exception as e:
        print(f"Failed to report result: {e}")

if __name__ == "__main__":
    register()
    while True:
        heartbeat()
        time.sleep(5)
