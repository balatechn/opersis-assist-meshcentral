# 🖥️ MeshCentral — Production Deployment (Coolify + Docker)

> **Self-hosted Remote Management & Monitoring (RMM) platform.**  
> Deploy MeshCentral on your own infrastructure with enterprise-grade security,  
> MongoDB persistence, and one-click Coolify deployment.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Coolify Server                     │
│                                                      │
│  ┌──────────────┐    ┌──────────────────────────┐   │
│  │   Traefik     │───▶│   MeshCentral Server     │   │
│  │  (Auto SSL)   │    │   (Node.js + Agents)     │   │
│  └──────────────┘    └───────────┬──────────────┘   │
│                                  │                   │
│                      ┌───────────▼──────────────┐   │
│                      │   MongoDB 7.0             │   │
│                      │   (Replica Set)           │   │
│                      └──────────────────────────┘   │
└─────────────────────────────────────────────────────┘
         ▲              ▲              ▲
         │              │              │
    ┌────┘    ┌─────────┘    ┌────────┘
    │         │              │
  Win PC   Linux Srv      Mac Device
  (Agent)   (Agent)        (Agent)
```

## ✨ Features

| Feature | Status |
|---------|--------|
| Remote Desktop (Browser) | ✅ |
| File Transfer | ✅ |
| Terminal (CMD/PS/SSH) | ✅ |
| Device Grouping | ✅ |
| User Roles & Permissions | ✅ |
| Unattended Access | ✅ |
| Basic Monitoring & Alerts | ✅ |
| MongoDB Persistence | ✅ |
| Auto SSL (Let's Encrypt) | ✅ |
| Docker Production Build | ✅ |
| Coolify One-Click Deploy | ✅ |
| Agent Auto-Deploy Scripts | ✅ |
| Backup & Restore | ✅ |

## 🚀 Quick Start

### Option 1: Coolify Deployment (Recommended)

1. **Push this repo** to your Git provider (GitHub/GitLab)
2. In Coolify → **New Resource** → **Docker Compose**
3. Connect your repository
4. Set environment variables (see `.env.example`)
5. Assign your domain (e.g., `mesh.yourdomain.com`)
6. **Deploy!** ✅

### Option 2: Direct Docker Compose

```bash
# 1. Clone the repository
git clone <your-repo-url> meshcentral-deploy
cd meshcentral-deploy

# 2. Configure environment
cp .env.example .env
nano .env  # Edit with your settings

# 3. Launch the stack
docker compose up -d

# 4. Check status
docker compose ps
docker compose logs -f meshcentral
```

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MC_HOSTNAME` | `mesh.example.com` | Your domain name |
| `MC_EXTERNAL_PORT` | `443` | External HTTPS port |
| `MC_REVERSE_PROXY` | `true` | Behind reverse proxy |
| `MONGO_PASSWORD` | `changeme` | MongoDB password |
| `MC_ALLOW_NEW_ACCOUNTS` | `false` | Allow self-registration |
| `MC_SMTP_HOST` | *(empty)* | SMTP server for emails |

See `.env.example` for the full list.

### First Login

1. Navigate to `https://mesh.yourdomain.com`
2. Create your **admin account** (first account = admin)
3. **Immediately disable** new account creation via the UI

## 📁 Project Structure

```
meshcentral-deploy/
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Stack definition (MC + MongoDB)
├── docker-entrypoint.sh    # Config generation & startup
├── .env.example            # Environment template
├── .dockerignore           # Clean build context
├── .gitignore              # Prevent secrets in git
├── README.md               # This file
└── scripts/
    ├── mongo-init-replica.sh    # MongoDB replica set init
    ├── deploy-agent-windows.ps1 # Windows agent installer
    ├── deploy-agent-linux.sh    # Linux agent installer
    ├── deploy-agent-mac.sh      # macOS agent installer
    ├── backup.sh                # Automated backup
    ├── restore.sh               # Disaster recovery
    └── health-check.sh          # Health monitoring
```

## 📦 Data Persistence

| Volume | Path | Purpose |
|--------|------|---------|
| `meshcentral-data` | `/opt/meshcentral/meshcentral-data` | Config, certs, DB |
| `meshcentral-files` | `/opt/meshcentral/meshcentral-files` | Uploaded files |
| `meshcentral-backups` | `/opt/meshcentral/meshcentral-backups` | Backup archives |
| `mongodb-data` | `/data/db` | MongoDB database |

## 🔐 Security Checklist

- [ ] Change default MongoDB password
- [ ] Set a strong `MC_SESSION_KEY`
- [ ] Disable new account registration
- [ ] Enable 2FA for admin accounts
- [ ] Configure firewall rules
- [ ] Set up SMTP for password recovery
- [ ] Review and harden `config.json`

## 📝 License

MIT — Use freely for your infrastructure.
