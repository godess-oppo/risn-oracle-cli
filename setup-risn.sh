#!/bin/bash
cd ~/risn-cli

# Fix permissions
chmod +x bin/risn
chmod +x src/commands/*.sh
chmod +x src/lib/*.sh

# Set up environment
echo "export RISN_HOME=\"$(pwd)\"" >> ~/.bashrc
echo 'export PATH="$PATH:$RISN_HOME/bin"' >> ~/.bashrc

# Reload environment
source ~/.bashrc

echo "RISN CLI setup complete!"
echo "Try: risn --help"
