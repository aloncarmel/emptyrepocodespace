#!/bin/bash
set -e

# Install tmux and ttyd (web terminal server)
sudo apt-get update
sudo apt-get install -y tmux

# Install ttyd (lightweight web terminal)
wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -O /tmp/ttyd
sudo mv /tmp/ttyd /usr/local/bin/ttyd
sudo chmod +x /usr/local/bin/ttyd

echo "Setup complete! Run 'ttyd -p 7681 bash' to start the web terminal"