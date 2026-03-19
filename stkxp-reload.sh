#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# stkxp-reload.sh — Reload all Stack Expert services via PM2
#
# Usage:
#   ./stkxp-reload.sh            # zero-downtime reload (default)
#   ./stkxp-reload.sh restart    # full restart
#   ./stkxp-reload.sh status     # show PM2 status
#   ./stkxp-reload.sh logs       # tail logs for all apps
# ─────────────────────────────────────────────────────────────────────────────

ECOSYSTEM="/root/ecosystem.config.js"
CMD="${1:-reload}"

case "$CMD" in
  reload)
    echo "🔄 Reloading all Stack Expert services (zero-downtime)..."
    pm2 reload "$ECOSYSTEM"
    ;;
  restart)
    echo "🔁 Restarting all Stack Expert services..."
    pm2 restart "$ECOSYSTEM"
    ;;
  status)
    pm2 list
    ;;
  logs)
    pm2 logs --lines 50
    ;;
  *)
    echo "Usage: $0 [reload|restart|status|logs]"
    exit 1
    ;;
esac

echo ""
pm2 list
