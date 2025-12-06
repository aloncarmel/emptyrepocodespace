#!/bin/bash

# Start ttyd with tmux in background
echo "Starting ttyd on port 7681..."
nohup ttyd -p 7681 -W tmux new -A -s main > /tmp/ttyd.log 2>&1 &

# Wait for ttyd to start
sleep 2

# Make port 7681 public
echo "Making port 7681 public..."
gh codespace ports visibility 7681:public -c $CODESPACE_NAME 2>/dev/null || echo "Note: Could not auto-set port visibility"

echo "✓ Web terminal ready on port 7681"