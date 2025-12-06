#!/bin/bash

# ============================================
# CONFIG - Set your server URL here or via env
# ============================================
SERVER_URL="https://1f2e4a0b33d9.ngrok-free.app"

echo "Starting terminal services..."
echo "Server URL: $SERVER_URL"
echo "Codespace: $CODESPACE_NAME"

# Start ttyd in background
echo "Starting ttyd on port 7681..."
pkill ttyd 2>/dev/null || true
nohup ttyd -p 7681 -W bash > /tmp/ttyd.log 2>&1 &
sleep 2

# Check if ngrok auth token is set
if [ -z "$NGROK_AUTHTOKEN" ]; then
  echo "⚠ NGROK_AUTHTOKEN not set. Please set it as a codespace secret."
  echo "Get your token from: https://dashboard.ngrok.com/get-started/your-authtoken"
  exit 1
fi

# Start ngrok in background
echo "Starting ngrok tunnel..."
pkill ngrok 2>/dev/null || true
nohup ngrok http 7681 --log=stdout > /tmp/ngrok.log 2>&1 &
sleep 3

# Get ngrok public URL from API
echo "Getting ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [ -z "$NGROK_URL" ] || [ "$NGROK_URL" == "null" ]; then
  echo "✗ Failed to get ngrok URL"
  cat /tmp/ngrok.log
  exit 1
fi

echo "✓ ngrok URL: $NGROK_URL"

# Announce to server
echo "Announcing to server..."
curl -X POST "$SERVER_URL/api/announce" \
  -H "Content-Type: application/json" \
  -d "{\"codespace\": \"$CODESPACE_NAME\", \"url\": \"$NGROK_URL\"}"

echo ""
echo "✓ Terminal ready!"
echo "  ttyd: http://localhost:7681"
echo "  ngrok: $NGROK_URL"