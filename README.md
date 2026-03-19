# Stack Expert — Infrastructure

Repo central de configuration et d'orchestration pour tous les services Stack Expert.

## Architecture

```
stackexpert.tech (nginx)
├── / → stkxp-pub/dist (static)
├── /api/, /public/ → stkxp-app :3003
│
app.stackexpert.tech (nginx)
└── → stkxp-app :3003
│
api.stackexpert.tech / mcp.stackexpert.tech (nginx)
└── → stkxp-app :3003 (proxy)

Services Node.js (PM2)
├── stkxp-app        :3003  — Express + LangGraph + WebSocket
├── stkxp-mcp-server :3001  — MCP tools server
└── stkxp-api        :4000  — REST API dynamique
```

## Repos

| Repo | Description | Runtime |
|------|-------------|---------|
| [`stkxp-app`](https://github.com/pierdav/stkxp-app) | Frontend React + Backend Express | `tsx server/index.ts` |
| [`stkxp-mcp-server`](https://github.com/pierdav/stkxp-mcp-server) | MCP Tools Server | `node build/index.js` |
| [`stkxp-api`](https://github.com/pierdav/stkxp-api) | REST API | `node dist/server.js` |
| [`stkxp-pub`](https://github.com/pierdav/stackxp-dev) | Site marketing (static) | nginx |
| [`stkxp-backend`](https://github.com/pierdav/stkxp-backend) | Scripts ingestion / pipeline | scripts only |

## Setup initial (nouvelle VM)

### 1. Cloner tous les repos

```bash
cd /root
git clone https://github.com/pierdav/stkxp-app
git clone https://github.com/pierdav/stkxp-mcp-server
git clone https://github.com/pierdav/stkxp-api
git clone https://github.com/pierdav/stackxp-dev stkxp-pub
git clone https://github.com/pierdav/stkxp-backend
git clone https://github.com/pierdav/stkxp-infra
```

### 2. Configurer les variables d'environnement

```bash
# Copier et remplir les .env pour chaque repo
cp /root/stkxp-infra/.env.example /tmp/env-reference

cp /tmp/env-reference /root/stkxp-app/.env
cp /tmp/env-reference /root/stkxp-mcp-server/.env
cp /tmp/env-reference /root/stkxp-api/.env
# Éditer chaque .env avec les vraies valeurs
```

### 3. Installer PM2

```bash
npm install -g pm2
# ou via pnpm
pnpm add -g pm2
```

### 4. Lancer le setup automatique

```bash
cd /root/stkxp-infra
chmod +x scripts/setup.sh scripts/deploy.sh stkxp-reload.sh
./scripts/setup.sh
```

Le script setup.sh effectue :
1. `pnpm install` / `npm install` pour chaque repo
2. Build des apps compilées (`stkxp-mcp-server`, `stkxp-api`, `stkxp-app`, `stkxp-pub`)
3. Création des répertoires de logs
4. Démarrage PM2 via `ecosystem.config.js`
5. Configuration du démarrage automatique au reboot (`pm2 startup systemd`)

## Gestion quotidienne

### Status des services

```bash
pm2 list
# ou
./stkxp-reload.sh status
```

### Reload sans downtime

```bash
./stkxp-reload.sh
# ou
pm2 reload /root/stkxp-infra/ecosystem.config.js
```

### Redémarrage complet

```bash
./stkxp-reload.sh restart
```

### Logs en temps réel

```bash
pm2 logs                        # tous les services
pm2 logs stkxp-app              # un service spécifique
pm2 logs --lines 100            # 100 dernières lignes
./stkxp-reload.sh logs
```

### Déployer une mise à jour

```bash
# Tout déployer (pull + build + reload)
./scripts/deploy.sh

# Un service spécifique
./scripts/deploy.sh app    # stkxp-app
./scripts/deploy.sh mcp    # stkxp-mcp-server
./scripts/deploy.sh api    # stkxp-api
./scripts/deploy.sh pub    # stkxp-pub (rebuild static)
```

## Auto-restart au reboot (VM)

PM2 est configuré comme service systemd (`pm2-root.service`).
Au reboot, PM2 relance automatiquement les 3 services depuis le dump sauvegardé.

```bash
# Vérifier que le service est actif
systemctl status pm2-root

# Après tout changement dans PM2 → sauvegarder
pm2 save
```

## Fichiers clés

| Fichier | Rôle |
|---------|------|
| `ecosystem.config.js` | Configuration PM2 (scripts, env, logs, restart policy) |
| `stkxp-reload.sh` | Script utilitaire reload/restart/status/logs |
| `scripts/setup.sh` | Setup complet première installation |
| `scripts/deploy.sh` | Déploiement ciblé par service |
| `.env.example` | Référence des variables d'environnement |

## Ports & Services

| Service | Port | Protocole | Notes |
|---------|------|-----------|-------|
| stkxp-app | 3003 | HTTPS | Proxifié par nginx |
| stkxp-mcp-server | 3001 | HTTPS | Appels internes depuis stkxp-app |
| stkxp-api | 4000 | HTTP | REST API |
| nginx | 80/443 | HTTP/HTTPS | Reverse proxy + static stkxp-pub |
