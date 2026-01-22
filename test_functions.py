import requests
import time
import json

SERVER_URL = "http://127.0.0.1:5001"

def get_agent_id():
    try:
        with open('agent_id.txt', 'r') as f:
            return f.read().strip()
    except:
        print("Could not read agent_id.txt")
        return None

def run_test(command_name):
    agent_id = get_agent_id()
    if not agent_id: return

    print(f"\n--- Testing {command_name} ---")
    try:
        # Queue command
        resp = requests.post(f"{SERVER_URL}/api/command", json={"agent_id": agent_id, "command": command_name})
        data = resp.json()
        
        if data.get("status") != "queued":
            print(f"Failed to queue: {data}")
            return

        cmd_id = data["command_id"]
        print(f"Queued ID: {cmd_id}. Waiting...")

        # Poll
        for i in range(20): # Wait up to 40s
            time.sleep(2)
            resp = requests.get(f"{SERVER_URL}/api/command/{cmd_id}")
            res_data = resp.json()
            status = res_data.get("status")
            
            if status == "completed":
                print("Result:")
                print(res_data.get("result"))
                return
        
        print("Timeout.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Test read-only functions
    run_test("check_installed")
    run_test("list_hotfixes")
    run_test("check_third_party")
    # run_test("check_updates") # This might take a long time, maybe skip for now or run last
