#!/usr/bin/env python3
"""
Agent Manager for RISN v2 - Coordinates multiple store coding agents
"""

import asyncio
import importlib.util
import sys
from pathlib import Path

class AgentManager:
    def __init__(self):
        self.agents = {}
        self.agent_directory = Path(__file__).parent
        
    async def load_agents(self):
        """Load all agents in the agents directory"""
        agent_files = list(self.agent_directory.glob("agent_*.py"))
        
        for agent_file in agent_files:
            if agent_file.name != "agent_manager.py":
                await self.load_agent(agent_file)
    
    async def load_agent(self, agent_file: Path):
        """Load a single agent"""
        try:
            spec = importlib.util.spec_from_file_location(agent_file.stem, agent_file)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            
            # Assuming each agent has a main agent class with the same name pattern
            agent_class_name = ''.join([word.capitalize() for word in agent_file.stem.split('_')])
            agent_class = getattr(module, agent_class_name, None)
            
            if agent_class:
                agent_instance = agent_class()
                if hasattr(agent_instance, 'initialize'):
                    await agent_instance.initialize()
                
                self.agents[agent_file.stem] = agent_instance
                print(f"[AgentManager] ✅ Loaded {agent_file.stem}")
                
        except Exception as e:
            print(f"[AgentManager] ❌ Failed to load {agent_file.name}: {e}")
    
    async def start_all_agents(self):
        """Start all loaded agents"""
        tasks = []
        for name, agent in self.agents.items():
            if hasattr(agent, 'run'):
                task = asyncio.create_task(agent.run())
                tasks.append(task)
                print(f"[AgentManager] 🚀 Started {name}")
        
        return tasks
    
    async def stop_all_agents(self):
        """Stop all running agents"""
        for name, agent in self.agents.items():
            if hasattr(agent, 'stop'):
                await agent.stop()
                print(f"[AgentManager] 🛑 Stopped {name}")

async def main():
    manager = AgentManager()
    await manager.load_agents()
    
    print(f"[AgentManager] 🎯 Loaded {len(manager.agents)} agents")
    
    try:
        tasks = await manager.start_all_agents()
        await asyncio.gather(*tasks)
    except KeyboardInterrupt:
        print("[AgentManager] 👋 Shutting down all agents...")
        await manager.stop_all_agents()

if __name__ == "__main__":
    asyncio.run(main())
