#!/bin/sh
# ============================================================================
# MeshCentral Docker Entrypoint Script
# Handles config generation, environment variable injection, and startup
# ============================================================================

set -e

CONFIG_DIR="/opt/meshcentral/meshcentral-data"
CONFIG_FILE="${CONFIG_DIR}/config.json"

echo "┌──────────────────────────────────────────────┐"
echo "│  🖥️  MeshCentral Production Server            │"
echo "│  Starting up...                               │"
echo "└──────────────────────────────────────────────┘"

# ── Generate config.json if it doesn't exist ──
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "⚙️  No config.json found. Generating production configuration..."
    
    # Set defaults for environment variables
    MC_HOSTNAME="${MC_HOSTNAME:-localhost}"
    MC_PORT="${MC_PORT:-443}"
    MC_MONGODB="${MC_MONGODB:-mongodb://mongodb:27017/meshcentral}"
    MC_REVERSE_PROXY="${MC_REVERSE_PROXY:-false}"
    MC_REVERSE_PROXY_PORT="${MC_REVERSE_PROXY_PORT:-443}"
    MC_ALLOW_NEW_ACCOUNTS="${MC_ALLOW_NEW_ACCOUNTS:-false}"
    MC_ALLOW_LOGIN_TOKEN="${MC_ALLOW_LOGIN_TOKEN:-true}"
    MC_ALLOW_FRAME="${MC_ALLOW_FRAME:-false}"
    MC_MINIFY="${MC_MINIFY:-true}"
    MC_SESSION_KEY="${MC_SESSION_KEY:-$(openssl rand -hex 32)}"
    MC_WEBRTC="${MC_WEBRTC:-false}"
    MC_SMTP_HOST="${MC_SMTP_HOST:-}"
    MC_SMTP_PORT="${MC_SMTP_PORT:-587}"
    MC_SMTP_FROM="${MC_SMTP_FROM:-}"
    MC_SMTP_USER="${MC_SMTP_USER:-}"
    MC_SMTP_PASS="${MC_SMTP_PASS:-}"
    MC_SMTP_TLS="${MC_SMTP_TLS:-true}"

    # Build config.json
    cat > "${CONFIG_FILE}" << CONFIGEOF
{
  "\$schema": "https://raw.githubusercontent.com/Ylianst/MeshCentral/master/meshcentral-config-schema.json",
  "settings": {
    "MongoDb": "${MC_MONGODB}",
    "MongoDbName": "meshcentral",
    "Cert": "${MC_HOSTNAME}",
    "Port": ${MC_PORT},
    "AliasPort": ${MC_REVERSE_PROXY_PORT},
    "RedirPort": 80,
    "TlsOffload": ${MC_REVERSE_PROXY},
    "SelfUpdate": false,
    "AllowFraming": ${MC_ALLOW_FRAME},
    "WebRTC": ${MC_WEBRTC},
    "Minify": ${MC_MINIFY},
    "SessionKey": "${MC_SESSION_KEY}",
    "AllowLoginToken": ${MC_ALLOW_LOGIN_TOKEN},
    "AgentPing": 60,
    "AgentPong": 60,
    "AllowHighQualityDesktop": true,
    "agentCoreDump": false,
    "Compression": true,
    "WsCompression": true,
    "AgentWsCompression": true,
    "MaxInvalidLogin": {
      "time": 10,
      "count": 5,
      "coolofftime": 30
    }
  },
  "domains": {
    "": {
      "Title": "MeshCentral",
      "Title2": "Remote Management",
      "NewAccounts": ${MC_ALLOW_NEW_ACCOUNTS},
      "CertUrl": "https://${MC_HOSTNAME}",
      "GeoLocation": true,
      "agentNoProxy": true,
      "mstsc": true,
      "ssh": true,
      "LoginKey": "auto",
      "agentConfig": ["webPush"],
      "UserRequiredPasswordLength": 12,
      "Footer": "<a>Powered by Infra-Assist</a>"
    }
  }
}
CONFIGEOF

    # Add SMTP configuration if provided
    if [ -n "${MC_SMTP_HOST}" ] && [ -n "${MC_SMTP_FROM}" ]; then
        echo "📧 SMTP configuration detected. Adding email settings..."
        # Use a temp file approach to add SMTP to config
        SMTP_CONFIG=$(cat << SMTPEOF
{
  "smtp": {
    "host": "${MC_SMTP_HOST}",
    "port": ${MC_SMTP_PORT},
    "from": "${MC_SMTP_FROM}",
    "user": "${MC_SMTP_USER}",
    "pass": "${MC_SMTP_PASS}",
    "tls": ${MC_SMTP_TLS}
  }
}
SMTPEOF
)
        # Merge SMTP into existing config (using node since we have it)
        node -e "
          const fs = require('fs');
          const config = JSON.parse(fs.readFileSync('${CONFIG_FILE}', 'utf8'));
          const smtp = ${SMTP_CONFIG};
          config.domains[''].smtp = smtp.smtp;
          fs.writeFileSync('${CONFIG_FILE}', JSON.stringify(config, null, 2));
        "
    fi

    echo "✅ config.json generated successfully!"
else
    echo "✅ Existing config.json found. Using current configuration."
fi

echo ""
echo "🔧 Configuration:"
echo "   Hostname: ${MC_HOSTNAME:-$(cat ${CONFIG_FILE} | node -e "const c=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(c.settings.Cert||'localhost')")}"
echo "   Port: ${MC_PORT:-443}"
echo "   Reverse Proxy: ${MC_REVERSE_PROXY:-false}"
echo ""
echo "🚀 Starting MeshCentral server..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start MeshCentral
exec node node_modules/meshcentral
