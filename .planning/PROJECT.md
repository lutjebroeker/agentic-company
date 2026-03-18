# Agentic Company — Execution Engine

## What This Is

Persoonlijke AI-infrastructuur voor Jelle Spek die twee producten ondersteunt: de **Execution Engine** (lokaal-eerste AI accountability systeem op basis van 12 Week Year) en **Logisch** (AI automation consultancy met Daan). De repo bevat alle skills, memory, patterns en automatiseringslogica — en is zelf verkoopbaar als product aan IT-professionals en PMs die het executiegat kennen.

## Core Value

Een werkend systeem dat dagelijks accountability afdwingt via DRIFT/MEET, zodat Jelle elke week op koers blijft richting €4.500/maand side income voor 1 juni 2026.

## Requirements

### Validated

- ✓ Alle 8 skills gebouwd (ceo, marketing, sales, ops, personal, review, learn, ship) — Fase 0
- ✓ memory/ architectuur aangemaakt (context, icp, offer-stack, pipeline) — Fase 0
- ✓ learning/ zelflerend geheugen (wins, fails, improvements, changelog) — Fase 0
- ✓ post-session.sh + notification.sh hooks gebouwd — Fase 0
- ✓ VPS template setup.sh gebouwd (products/vps-template/) — Fase 0
- ✓ Cherry-picked Fabric patterns (extract_wisdom, create_newsletter, etc.) — Fase 0
- ✓ GitHub issues + milestones aangemaakt (Fase 0-4, 16 issues) — Fase 0

### Active

- [ ] Always-on Telegram + Slack agent interface (n8n workflows)
- [ ] Proactieve n8n workflows (content briefing, engagement scan, /learn synthesize)
- [ ] Open Brain semantisch geheugen (Supabase pgvector)
- [ ] Tone of Voice Guide (n8n workflow → memory/tone-of-voice.md)
- [ ] Signal Agent (audio → transcriptie → Obsidian)
- [ ] NuggetHunter Intelligence Engine
- [ ] VPS template getest op schone Hetzner CAX11
- [ ] Eerste beta-klant + case study
- [ ] DRIFT+MEET IP-reeks op LinkedIn
- [ ] De Execution Log nieuwsbrief

### Out of Scope

- Pre-tool-use hook — gedragsregel in CLAUDE.md is effectiever en minder fragiel
- Submodules voor Fabric — cherry-picked patterns volstaan
- Open Brain self-hosted (Proxmox) — pas na Supabase Cloud bewezen
- products/execution-engine/ directory — pas na beta traject

## Context

**Stack (actief op Proxmox thuis, Enkhuizen):**
- n8n Starfleet (zelf-gehost LXC), Ollama LLaMA 3.1, Obsidian vault
- Claude Code (deze repo), Telegram bot, Cloudflare Tunnel
- Home Assistant (KPI dashboard), n8n-mcp (czlonkowski)
- Open Brain MCP (Supabase pgvector — nog op te zetten)

**Vier architectuurlagen:**
1. Interface: Claude.ai · Claude Code · Telegram · Slack
2. Memory: Open Brain (wat je zegt) · Obsidian (wat je schrijft) · Ziplined
3. Structuur: agentic-company repo → sync.sh → ~/.claude/
4. Automaat: n8n Starfleet · Home Assistant · Proxmox

**IP Modellen:**
- DRIFT-patroon (probleem): Doel → Routine wegzakt → Intentie ≠ Actie → Feedback ontbreekt → Tolerantie voor uitstel
- MEET-cyclus (oplossing): Meten · Eerlijk confronteren · Evalueren · Terugkoppelen
- Elevator pitch: "De meeste mensen driften weg — het DRIFT-patroon. De Execution Engine doorbreekt dat via de MEET-cyclus."

## Constraints

- **Tijd**: 8–12 uur per week beschikbaar naast fulltime baan Enza Zaden
- **Tijdlijn**: 1 juni 2026 = Execution Engine launch
- **Revenue target**: €4.500/maand — pad: 0 → €1.744 (maand 3-4) → €4.535 (maand 5-6)
- **Stack**: ESM modules, n8n via MCP (geen JSON export), sync.sh als deploymechanisme

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| claude-config/ als source of truth (niet ~/.claude/) | Portable config, sync via sync.sh | ✓ Good |
| Memory laadt niet automatisch bij sessiestart | Vermijdt context overhead — per skill geladen | ✓ Good |
| n8n-mcp gebruiken (direct in Starfleet bouwen) | Geen JSON roundtrip, direct valideerbaar | — Pending |
| Supabase Cloud voor Open Brain (niet self-hosted) | Bewijs eerst, infrastructuur later | — Pending |
| Fase 0 grotendeels klaar bij GSD-initialisatie | Brownfield project, niet greenfield | ✓ Good |

---
*Last updated: 2026-03-18 bij GSD initialisatie*
