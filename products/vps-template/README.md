# Execution Engine — VPS Template

Complete installatie van de Execution Engine stack op een Hetzner VPS.

## Wat wordt geïnstalleerd

| Component | Functie | Poort |
|---|---|---|
| n8n | Workflow automation | 5678 |
| CouchDB | Obsidian LiveSync backend | 5984 |
| Ollama | Local LLM (optioneel) | 11434 |

Alles draait in Docker containers op een Hetzner CAX11 (ARM64, Ubuntu 24.04).

## Installatie

### Optie 1: Eén commando
```bash
curl -fsSL https://raw.githubusercontent.com/lutjebroeker/agentic-company/main/products/vps-template/setup.sh | sudo bash
```

### Optie 2: Clone + run
```bash
git clone https://github.com/lutjebroeker/agentic-company.git
cd agentic-company/products/vps-template
sudo ./setup.sh
```

### Zonder Ollama
```bash
sudo ./setup.sh --no-ollama
```

## Na installatie

1. **n8n** — Open `http://<jouw-ip>:5678` en maak een owner account aan
2. **CouchDB wachtwoord** — Wijzig in `/opt/execution-engine/docker-compose.yml`
3. **Workflows** — Importeer JSON bestanden uit `workflows/` via n8n UI
4. **Firewall** — Standaard open: SSH + n8n. Voeg poorten toe indien nodig:
   ```bash
   sudo ufw allow 5984/tcp  # CouchDB (alleen als extern nodig)
   ```

## Configuratie

Omgevingsvariabelen (stel in vóór setup):

| Variabele | Default | Beschrijving |
|---|---|---|
| `N8N_PORT` | 5678 | n8n web UI poort |
| `COUCHDB_PORT` | 5984 | CouchDB poort |
| `COUCHDB_USER` | admin | CouchDB gebruiker |
| `COUCHDB_PASSWORD` | changeme | CouchDB wachtwoord |
| `OLLAMA_PORT` | 11434 | Ollama API poort |

## Beheer

```bash
cd /opt/execution-engine

docker compose ps        # Status
docker compose logs -f   # Logs volgen
docker compose restart   # Herstarten
docker compose pull      # Updates ophalen
docker compose up -d     # Updaten na pull
```

## Workflows

Drop n8n workflow JSON bestanden in de `workflows/` map. Deze worden automatisch geïmporteerd bij setup, of handmatig via de n8n UI.
