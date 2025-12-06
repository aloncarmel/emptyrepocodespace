#!/bin/bash
set -e

# Install tmux
sudo apt-get update
sudo apt-get install -y tmux

# Install ttyd (web terminal server)
wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -O /tmp/ttyd
sudo mv /tmp/ttyd /usr/local/bin/ttyd
sudo chmod +x /usr/local/bin/ttyd

echo "✓ Setup complete - tmux and ttyd installed"