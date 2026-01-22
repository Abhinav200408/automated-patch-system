from flask import Flask, render_template, jsonify, request
import database
import os
import socket

app = Flask(__name__)

# Initialize DB
database.init_db()

@app.route('/')
def index():
    agents = database.get_all_agents()
    
    # Calculate Stats
    total_agents = len(agents)
    online_agents = sum(1 for a in agents if a['status'] == 'online')
    offline_agents = total_agents - online_agents
    
    server_hostname = socket.gethostname()
    
    return render_template('dashboard.html', agents=agents, 
                           total=total_agents, online=online_agents, offline=offline_agents,
                           server_hostname=server_hostname)

@app.route('/agent/<agent_id>')
def agent_detail(agent_id):
    # In a real app, fetch agent details. For now, pass ID.
    return render_template('agent_detail.html', agent_id=agent_id)

@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    database.register_agent(data['id'], data['hostname'], data['ip_address'])
    return jsonify({"status": "registered"})

@app.route('/api/heartbeat', methods=['POST'])
def heartbeat():
    data = request.json
    agent_id = data['id']
    database.update_heartbeat(agent_id)
    
    commands = database.get_pending_commands(agent_id)
    command_list = [{"id": cmd[0], "command": cmd[1]} for cmd in commands]
    
    return jsonify({"commands": command_list})

@app.route('/api/report', methods=['POST'])
def report():
    data = request.json
    command_id = data.get('command_id')
    result = data.get('result')
    print(f"Received report for command {command_id}, result length: {len(str(result))}")
    if command_id:
        database.complete_command(command_id, result)
        print(f"Command {command_id} marked as completed.")
    return jsonify({"status": "received"})

@app.route('/api/command', methods=['POST'])
def send_command():
    data = request.json
    agent_id = data['agent_id']
    command = data['command']
    cmd_id = database.queue_command(agent_id, command)
    return jsonify({"status": "queued", "command_id": cmd_id})

@app.route('/api/command/<int:command_id>')
def get_command_status(command_id):
    result = database.get_command_result(command_id)
    if result:
        return jsonify(result)
    return jsonify({"error": "Command not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=False)
