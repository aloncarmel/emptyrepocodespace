#!/bin/bash

# ============================================
# CONFIG - Update this with your server URL
# ============================================
SERVER_URL="https://1f2e4a0b33d9.ngrok-free.app"

echo "Starting Claude Code terminal..."
echo "Codespace: $CODESPACE_NAME"

# Kill any existing processes
pkill ttyd 2>/dev/null || true
pkill cloudflared 2>/dev/null || true
sleep 1

# Start ttyd running Claude Code directly
# The -W flag makes it writable (allows input)
echo "Starting ttyd with Claude Code..."
nohup ttyd -p 7681 -W claude > /tmp/ttyd.log 2>&1 &
sleep 2

# Verify ttyd is running
if ! pgrep ttyd > /dev/null; then
  echo "✗ ttyd failed to start"
  cat /tmp/ttyd.log
  exit 1
fi
echo "✓ ttyd running with Claude Code"

# Start cloudflared tunnel
echo "Starting cloudflared tunnel..."
nohup cloudflared tunnel --url http://localhost:7681 > /tmp/cloudflared.log 2>&1 &
sleep 5

# Get tunnel URL
TUNNEL_URL=$(grep -o 'https://[^[:space:]]*\.trycloudflare\.com' /tmp/cloudflared.log | head -1)

if [ -z "$TUNNEL_URL" ]; then
  echo "✗ Failed to get tunnel URL"
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
echo "✓ Claude Code terminal ready!"
echo "  Local: http://localhost:7681"
echo "  Tunnel: $TUNNEL_URL"