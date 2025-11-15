#!/bin/bash
# Start all RISN v2 agents

echo "🚀 Starting RISN v2 Agent System..."
cd "$(dirname "$0")"

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Start the agent manager
python3 agents/agent_manager.py

echo "🛑 RISN v2 Agent System stopped"
