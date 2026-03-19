#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# setup.sh — First-time setup for Stack Expert services
#
# Run once after cloning all repos on a new VM.
# Assumes all repos are cloned under /root/.
# ─────────────────────────────────────────────────────────────────────────────
set -e

echo "═══════════════════════════════════════════"
echo "  Stack Expert — First-time setup"
echo "═══════════════════════════════════════════"

# ── 1. Install dependencies ─────────────────────────────────────────────────
echo ""
echo "▶ [1/5] Installing dependencies..."

echo "  → stkxp-app"
cd /root/stkxp-app && pnpm install --frozen-lockfile

echo "  → stkxp-mcp-server"
cd /root/stkxp-mcp-server && pnpm install --frozen-lockfile

echo "  → stkxp-api"
cd /root/stkxp-api && npm install

# ── 2. Build compiled apps ──────────────────────────────────────────────────
echo ""
echo "▶ [2/5] Building apps..."

echo "  → stkxp-mcp-server (swc build)"
cd /root/stkxp-mcp-server && npm run build

echo "  → stkxp-api (tsc build)"
cd /root/stkxp-api && npm run build

echo "  → stkxp-app (vite build)"
cd /root/stkxp-app && npm run build

echo "  → stkxp-pub (vite build)"
cd /root/stkxp-pub && npm run build

# ── 3. Create log directories ───────────────────────────────────────────────
echo ""
echo "▶ [3/5] Creating log directories..."
mkdir -p /root/stkxp-app/logs
mkdir -p /root/stkxp-mcp-server/logs
mkdir -p /root/stkxp-api/logs

# ── 4. Start services via PM2 ───────────────────────────────────────────────
echo ""
echo "▶ [4/5] Starting services with PM2..."
pm2 start /root/stkxp-infra/ecosystem.config.js
sleep 3
pm2 list

# ── 5. Configure PM2 auto-start on reboot ──────────────────────────────────
echo ""
echo "▶ [5/5] Configuring PM2 startup on reboot..."
pm2 save
pm2 startup systemd -u root --hp /root | tail -5

echo ""
echo "══════════════════════════════════════════════════"
echo "  ✅ Setup complete!"
echo ""
echo "  Services running:"
echo "    stkxp-app        → https://localhost:3003"
echo "    stkxp-mcp-server → https://localhost:3001/mcp"
echo "    stkxp-api        → http://localhost:4000"
echo "    stkxp-pub        → served by nginx (static)"
echo ""
echo "  Management:"
echo "    ./stkxp-reload.sh          # reload all"
echo "    ./stkxp-reload.sh status   # status"
echo "    pm2 logs                   # live logs"
echo "══════════════════════════════════════════════════"
