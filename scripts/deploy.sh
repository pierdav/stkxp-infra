#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — Pull latest code and redeploy all services
#
# Usage:
#   ./scripts/deploy.sh            # deploy all apps
#   ./scripts/deploy.sh app        # deploy only stkxp-app
#   ./scripts/deploy.sh mcp        # deploy only stkxp-mcp-server
#   ./scripts/deploy.sh api        # deploy only stkxp-api
#   ./scripts/deploy.sh pub        # deploy only stkxp-pub (static rebuild)
# ─────────────────────────────────────────────────────────────────────────────
set -e

TARGET="${1:-all}"

deploy_app() {
  echo "▶ Deploying stkxp-app..."
  cd /root/stkxp-app
  git pull origin main
  pnpm install
  npm run build
  pm2 reload stkxp-app
  echo "  ✅ stkxp-app reloaded"
}

deploy_mcp() {
  echo "▶ Deploying stkxp-mcp-server..."
  cd /root/stkxp-mcp-server
  git pull origin main
  pnpm install
  npm run build
  pm2 reload stkxp-mcp-server
  echo "  ✅ stkxp-mcp-server reloaded"
}

deploy_api() {
  echo "▶ Deploying stkxp-api..."
  cd /root/stkxp-api
  git pull origin main
  npm install
  npm run build
  pm2 reload stkxp-api
  echo "  ✅ stkxp-api reloaded"
}

deploy_pub() {
  echo "▶ Deploying stkxp-pub (static)..."
  cd /root/stkxp-pub
  git pull origin main
  npm install
  npm run build
  echo "  ✅ stkxp-pub rebuilt (nginx serves /dist automatically)"
}

case "$TARGET" in
  all)
    deploy_mcp
    deploy_api
    deploy_app
    deploy_pub
    ;;
  app)  deploy_app ;;
  mcp)  deploy_mcp ;;
  api)  deploy_api ;;
  pub)  deploy_pub ;;
  *)
    echo "Usage: $0 [all|app|mcp|api|pub]"
    exit 1
    ;;
esac

echo ""
pm2 list
