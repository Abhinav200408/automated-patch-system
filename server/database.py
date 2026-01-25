import sqlite3
import os
from datetime import datetime

DB_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'agents.db')

def init_db():
    # Ensure the directory exists (it should, since this file is in it)
    db_dir = os.path.dirname(DB_FILE)
    os.makedirs(db_dir, exist_ok=True)
    
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS agents (
            id TEXT PRIMARY KEY,
            hostname TEXT,
            ip_address TEXT,
            last_seen TIMESTAMP,
            status TEXT,
            last_update_log TEXT
        )
    ''')
    c.execute('''
        CREATE TABLE IF NOT EXISTS commands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agent_id TEXT,
            command TEXT,
            status TEXT DEFAULT 'pending',
            result TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(agent_id) REFERENCES agents(id)
        )
    ''')
    conn.commit()
    conn.close()

def register_agent(agent_id, hostname, ip_address):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    now = datetime.now()
    c.execute('''
        INSERT OR REPLACE INTO agents (id, hostname, ip_address, last_seen, status)
        VALUES (?, ?, ?, ?, ?)
    ''', (agent_id, hostname, ip_address, now, 'online'))
    conn.commit()
    conn.close()

def update_heartbeat(agent_id):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    now = datetime.now()
    c.execute('UPDATE agents SET last_seen = ?, status = ? WHERE id = ?', (now, 'online', agent_id))
    conn.commit()
    conn.close()

def get_pending_commands(agent_id):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT id, command FROM commands WHERE agent_id = ? AND status = ?', (agent_id, 'pending'))
    commands = c.fetchall()
    conn.close()
    return commands

def complete_command(command_id, result=None):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('UPDATE commands SET status = ?, result = ? WHERE id = ?', ('completed', result, command_id))
    conn.commit()
    conn.close()

def queue_command(agent_id, command):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('INSERT INTO commands (agent_id, command) VALUES (?, ?)', (agent_id, command))
    new_id = c.lastrowid
    conn.commit()
    conn.close()
    return new_id

def get_all_agents():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('SELECT * FROM agents')
    agents = [dict(row) for row in c.fetchall()]
    conn.close()
    return agents

def get_agent_details(agent_id):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('SELECT * FROM agents WHERE id = ?', (agent_id,))
    row = c.fetchone()
    conn.close()
    if row:
        return dict(row)
    return None

def get_command_result(command_id):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT status, result FROM commands WHERE id = ?', (command_id,))
    row = c.fetchone()
    conn.close()
    if row:
        return {"status": row[0], "result": row[1]}
    return None
