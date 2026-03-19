/**
 * PM2 Ecosystem — Stack Expert
 *
 * Apps managed:
 *   - stkxp-app      (port 3003) — Express + LangGraph backend
 *   - stkxp-mcp-server (port 3001) — MCP server (pre-built)
 *   - stkxp-api      (port 4000) — REST API (pre-built)
 *
 * stkxp-pub is static, served directly by nginx — no Node process needed.
 *
 * Usage:
 *   pm2 start /root/ecosystem.config.js    # start all
 *   pm2 reload /root/ecosystem.config.js   # zero-downtime reload
 *   pm2 restart /root/ecosystem.config.js  # full restart
 *   pm2 stop /root/ecosystem.config.js     # stop all
 */

module.exports = {
  apps: [
    // ─── stkxp-app ──────────────────────────────────────────────────────────
    {
      name: "stkxp-app",
      cwd: "/root/stkxp-app",
      script: "./node_modules/.bin/tsx",
      args: "server/index.ts",
      interpreter: "node",
      env: {
        NODE_ENV: "production",
        CONSOLE_LOGS: "false",
      },
      // Logs
      out_file: "/root/stkxp-app/logs/pm2-out.log",
      error_file: "/root/stkxp-app/logs/pm2-error.log",
      merge_logs: true,
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      // Restart policy
      autorestart: true,
      restart_delay: 3000,
      max_restarts: 10,
      watch: false,
    },

    // ─── stkxp-mcp-server ───────────────────────────────────────────────────
    {
      name: "stkxp-mcp-server",
      cwd: "/root/stkxp-mcp-server",
      script: "build/index.js",
      interpreter: "node",
      env: {
        NODE_ENV: "production",
        CONSOLE_LOGS: "false",
      },
      // Logs
      out_file: "/root/stkxp-mcp-server/logs/pm2-out.log",
      error_file: "/root/stkxp-mcp-server/logs/pm2-error.log",
      merge_logs: true,
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      // Restart policy
      autorestart: true,
      restart_delay: 3000,
      max_restarts: 10,
      watch: false,
    },

    // ─── stkxp-api ──────────────────────────────────────────────────────────
    {
      name: "stkxp-api",
      cwd: "/root/stkxp-api",
      script: "dist/server.js",
      interpreter: "node",
      env: {
        NODE_ENV: "production",
      },
      // Logs
      out_file: "/root/stkxp-api/logs/pm2-out.log",
      error_file: "/root/stkxp-api/logs/pm2-error.log",
      merge_logs: true,
      log_date_format: "YYYY-MM-DD HH:mm:ss",
      // Restart policy
      autorestart: true,
      restart_delay: 3000,
      max_restarts: 10,
      watch: false,
    },
  ],
};
