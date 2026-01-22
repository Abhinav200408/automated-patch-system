import requests
import time
import json

SERVER_URL = "http://127.0.0.1:5001"

def verify():
    print(f"Checking server at {SERVER_URL}...")
    try:
        # 1. Get Agents
        resp = requests.get(f"{SERVER_URL}/")
        if resp.status_code != 200:
            print(f"Failed to load dashboard: {resp.status_code}")
            return
        
        print("Dashboard reachable.")
        
        # We need an agent ID. Let's assume the local one is registered.
        # Since we can't easily parse HTML here without bs4, let's just use the API if possible.
        # But there is no public API to list agents in the code I saw (only rendered in template).
        # Wait, app.py has:
        # @app.route('/') -> render_template
        # But database.py has get_all_agents().
        
        # Let's peek at the DB directly to get an ID, or just rely on the agent we know is running.
        # Actually, the agent saves its ID to 'agent_id.txt'.
        
        with open('agent_id.txt', 'r') as f:
            agent_id = f.read().strip()
            
        print(f"Found Agent ID: {agent_id}")
        
        # 2. Send Command
        print("Sending 'check_installed' command...")
        payload = {"agent_id": agent_id, "command": "check_installed"}
        resp = requests.post(f"{SERVER_URL}/api/command", json=payload)
        data = resp.json()
        
        if data.get("status") == "queued":
            cmd_id = data["command_id"]
            print(f"Command queued with ID: {cmd_id}")
            
            # 3. Poll for result
            for i in range(10):
                time.sleep(2)
                resp = requests.get(f"{SERVER_URL}/api/command/{cmd_id}")
                res_data = resp.json()
                status = res_data.get("status")
                print(f"Poll {i+1}: {status}")
                
                if status == "completed":
                    print("\nCommand Completed Successfully!")
                    print("Result output (truncated):")
                    print(res_data.get("result")[:500] + "...")
                    return
            
            print("Timed out waiting for command completion.")
        else:
            print(f"Failed to queue command: {data}")

    except Exception as e:
        print(f"Verification failed: {e}")

if __name__ == "__main__":
    verify()
