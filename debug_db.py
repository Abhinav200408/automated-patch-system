from server import database
import sqlite3

try:
    conn = sqlite3.connect('server/agents.db')
    c = conn.cursor()
    c.execute("SELECT id, command, status, length(result) FROM commands WHERE id IN (17, 18)")
    rows = c.fetchall()
    print("Recent Commands:")
    for row in rows:
        print(row)
    conn.close()
except Exception as e:
    print("Error:", e)
