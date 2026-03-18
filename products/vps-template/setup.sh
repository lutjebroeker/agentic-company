#!/bin/bash
# setup.sh — Execution Engine VPS Setup
#
# Installeert de complete stack op een Hetzner CAX11 (ARM64, Ubuntu 24.04):
#   - Docker + Docker Compose
#   - n8n (workflow automation)
#   - Obsidian LiveSync (via CouchDB)
#   - Ollama (local LLM, optioneel)
#
# Gebruik:
#   curl -fsSL https://raw.githubusercontent.com/lutjebroeker/agentic-company/main/products/vps-template/setup.sh | bash
#   # of:
#   ./setup.sh                    # Volledige installatie
#   ./setup.sh --no-ollama        # Zonder Ollama
#
# Idempotent: veilig om meerdere keren te draaien.

set -euo pipefail

# --- Config ---
N8N_PORT="${N8N_PORT:-5678}"
COUCHDB_PORT="${COUCHDB_PORT:-5984}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"
INSTALL_OLLAMA=true
DATA_DIR="/opt/execution-engine"

[[ "${1:-}" == "--no-ollama" ]] && INSTALL_OLLAMA=false

# --- Kleuren ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# --- Pre-flight checks ---
echo "=========================================="
echo "  Execution Engine VPS Setup"
echo "=========================================="
echo ""

[[ $EUID -ne 0 ]] && err "Run als root: sudo ./setup.sh"

log "OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
log "Arch: $(uname -m)"

# --- System updates ---
log "Systeem updaten..."
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq curl git ufw jq

# --- Firewall ---
log "Firewall configureren..."
ufw allow OpenSSH
ufw allow "$N8N_PORT"/tcp comment "n8n"
ufw --force enable
log "Firewall actief (SSH + n8n)"

# --- Docker ---
if command -v docker &>/dev/null; then
    log "Docker al geïnstalleerd: $(docker --version)"
else
    log "Docker installeren..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    log "Docker geïnstalleerd: $(docker --version)"
fi

# --- Data directories ---
log "Data directories aanmaken..."
mkdir -p "$DATA_DIR"/{n8n,couchdb,ollama}

# --- Docker Compose ---
log "Docker Compose config schrijven..."
cat > "$DATA_DIR/docker-compose.yml" << 'COMPOSE'
services:
  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "${N8N_PORT:-5678}:5678"
    environment:
      - N8N_SECURE_COOKIE=false
      - N8N_DIAGNOSTICS_ENABLED=false
      - GENERIC_TIMEZONE=Europe/Amsterdam
      - TZ=Europe/Amsterdam
    volumes:
      - ./n8n:/home/node/.n8n
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 5s
      retries: 3

  couchdb:
    image: couchdb:3
    restart: unless-stopped
    ports:
      - "${COUCHDB_PORT:-5984}:5984"
    environment:
      - COUCHDB_USER=${COUCHDB_USER:-admin}
      - COUCHDB_PASSWORD=${COUCHDB_PASSWORD:-changeme}
    volumes:
      - ./couchdb:/opt/couchdb/data
COMPOSE

# Ollama toevoegen als gewenst
if [[ "$INSTALL_OLLAMA" == true ]]; then
    cat >> "$DATA_DIR/docker-compose.yml" << 'OLLAMA'

  ollama:
    image: ollama/ollama:latest
    restart: unless-stopped
    ports:
      - "${OLLAMA_PORT:-11434}:11434"
    volumes:
      - ./ollama:/root/.ollama
OLLAMA
    log "Ollama toegevoegd aan stack"
fi

# --- Start stack ---
log "Stack starten..."
cd "$DATA_DIR"
docker compose up -d

# --- Wacht op n8n ---
log "Wachten op n8n..."
for i in $(seq 1 30); do
    if curl -sf "http://localhost:$N8N_PORT/healthz" &>/dev/null; then
        log "n8n draait op poort $N8N_PORT"
        break
    fi
    sleep 2
done

# --- Import workflows ---
WORKFLOW_DIR="$(dirname "$0")/workflows"
if [[ -d "$WORKFLOW_DIR" ]] && ls "$WORKFLOW_DIR"/*.json &>/dev/null; then
    log "Workflows importeren..."
    for wf in "$WORKFLOW_DIR"/*.json; do
        name=$(basename "$wf" .json)
        log "  → $name"
        # n8n CLI import als n8n draait
        docker compose exec -T n8n n8n import:workflow --input=/dev/stdin < "$wf" 2>/dev/null || warn "  Import van $name mislukt — handmatig importeren via UI"
    done
fi

# --- Samenvatting ---
IP=$(curl -sf https://ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "  Setup compleet!"
echo "=========================================="
echo ""
echo "  n8n:        http://$IP:$N8N_PORT"
echo "  CouchDB:    http://$IP:$COUCHDB_PORT"
if [[ "$INSTALL_OLLAMA" == true ]]; then
echo "  Ollama:     http://$IP:$OLLAMA_PORT"
fi
echo ""
echo "  Data:       $DATA_DIR"
echo ""
echo "  Volgende stappen:"
echo "  1. Stel n8n owner account in via de browser"
echo "  2. Wijzig CouchDB wachtwoord (COUCHDB_PASSWORD)"
echo "  3. Importeer workflows uit workflows/ map"
echo ""
