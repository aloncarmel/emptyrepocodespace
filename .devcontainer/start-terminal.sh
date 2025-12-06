#!/bin/bash

# ============================================
# CONFIG
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

# Start cloudflared tunnel (no auth required for quick tunnels!)
echo "Starting cloudflared tunnel..."
pkill cloudflared 2>/dev/null || true
nohup cloudflared tunnel --url http://localhost:7681 > /tmp/cloudflared.log 2>&1 &
sleep 5

# Get cloudflared URL from logs
echo "Getting tunnel URL..."
TUNNEL_URL=$(grep -o 'https://[^[:space:]]*\.trycloudflare\.com' /tmp/cloudflared.log | head -1)

if [ -z "$TUNNEL_URL" ]; then
  echo "✗ Failed to get tunnel URL"
  echo "cloudflared log:"
  cat /tmp/cloudflared.log
  exit 1
fi

echo "✓ Tunnel URL: $TUNNEL_URL"

# Announce to server
echo "Announcing to server..."
curl -X POST "$SERVER_URL/api/announce" \
  -H "Content-Type: application/json" \
  -d "{\"codespace\": \"$CODESPACE_NAME\", \"url\": \"$TUNNEL_URL\"}"

echo ""
echo "✓ Terminal ready!"
echo "  ttyd: http://localhost:7681"
echo "  tunnel: $TUNNEL_URL"