import requests
import sys

try:
    print("Attempting to connect to http://127.0.0.1:5001...")
    r = requests.get("http://127.0.0.1:5001", timeout=5)
    print(f"Status Code: {r.status_code}")
    print(f"Content length: {len(r.text)}")
    print("Server is reachable!")
except Exception as e:
    print(f"Failed to connect: {e}")
    sys.exit(1)
