import requests

SERVER_URL = "http://127.0.0.1:5001"

def test_report():
    print("Testing report endpoint...")
    try:
        # 1. Queue a dummy command to get an ID (or just use a fake ID if DB allows, but DB update needs valid ID)
        # Let's queue one.
        with open('agent_id.txt', 'r') as f:
            agent_id = f.read().strip()
            
        resp = requests.post(f"{SERVER_URL}/api/command", json={"agent_id": agent_id, "command": "test_echo"})
        cmd_id = resp.json().get("command_id")
        print(f"Queued dummy command {cmd_id}")
        
        # 2. Report completion
        payload = {"command_id": cmd_id, "result": "Test Result"}
        print(f"Sending report: {payload}")
        resp = requests.post(f"{SERVER_URL}/api/report", json=payload)
        print(f"Response: {resp.status_code} {resp.text}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_report()
