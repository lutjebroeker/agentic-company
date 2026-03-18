# Phase 2: Core Skills Live - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Always-on chat interface via Telegram en Slack waarmee Jelle de 8 skills (ceo, marketing, sales, ops, personal, review, learn, ship) kan aanroepen via gewone berichten. Plus 3 proactieve n8n workflows die automatisch output sturen op vaste tijdstippen. Claude Code wordt aangeroepen via CLI, niet via directe Anthropic API (Jelle heeft Max abonnement, geen API key).

</domain>

<decisions>
## Implementation Decisions

### Telegram routing
- Gewone zinnen, geen expliciete slash commands — bot herkent skill via NLP
- Bij ambiguïteit: terugvragen welke skill bedoeld wordt ("Bedoel je /ceo of /sales?")
- Thread-context: laatste 5 berichten meesturen als conversatie-context
- Stateless per sessie (geen langetermijn-geheugen buiten de 5 berichten)

### Slack kanaalmodel
- 5 dedicated kanalen: #agent-ceo, #agent-marketing, #agent-sales, #agent-ops, #agent-personal
- Skill wordt bepaald door kanaal — geen NLP routing nodig in Slack
- Bot reageert altijd in thread (kanaal blijft overzichtelijk)
- Alleen Jelle mag triggeren (user-ID whitelist in n8n)
- Thread-context: bot leest thread history voor vervolgvragen

### Claude aanroepen in n8n
- Claude Code CLI via SSH: n8n → Proxmox host → `claude -p "..."`
- n8n en Claude Code draaien op dezelfde Proxmox server (SSH toegang beschikbaar)
- Skill prompt als -p argument: `claude -p "$(cat ~/.claude/commands/{skill}.md)\n\nVraag: {user_message}"`
- Geen directe Anthropic API (vereist apart API account — Jelle heeft Max abonnement)

### Proactieve workflows

**Maandag 07:00 — Content briefing:**
- Input: learning/wins.md + fails.md + improvements.md van afgelopen week
- Verwerking: synthesize via /learn → gestructureerd briefing document
- Output: Telegram bericht (wat werkte, wat niet, welk verhaal zit daarin)
- Jelle beslist zelf wat content wordt en stuurt door naar Ziplined

**Dagelijks 09:00 — DM-suggesties (#agent-sales):**
- Input: memory/pipeline.md (opvolging op basis van laatste contact-datum) + LinkedIn signalen (likes/comments op posts)
- Output: Slack thread in #agent-sales met concrete DM-suggesties voor die dag

**Zondag 18:00 — Wekelijkse /learn synthesize:**
- Input: wins.md + fails.md + improvements.md van die week
- Output: Telegram bericht (wat werkte, wat niet, 1 aanpassing voor volgende week) + improvements.md automatisch bijgewerkt

### Claude's Discretion
- Exacte NLP routing-logica voor Telegram (welk model/prompt voor skill-detectie)
- LinkedIn signalen ophalen: specifieke API aanpak of scraping
- Format en lengte van Telegram berichten
- Error handling en retry-gedrag bij CLI timeout

</decisions>

<specifics>
## Specific Ideas

- Content briefing is geen content-generator maar een verwerker: Ziplined heeft al een strategie, de briefing voedt die aan met insights uit de Execution Engine
- SSH bridge tussen n8n en Proxmox host als pragmatische oplossing voor Claude Code toegang zonder aparte API kosten

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `claude-config/hooks/notification.sh`: bestaand Telegram notificatie-script — herbruikbaar pattern voor proactieve Telegram output
- `claude-config/commands/*.md`: 8 skill-prompt bestanden — direct te gebruiken als -p argument in CLI calls
- `memory/pipeline.md`: bestaande pipeline data — directe input voor dagelijkse DM-suggesties
- `learning/wins.md`, `learning/fails.md`, `learning/improvements.md`: bestaande learning files — input voor maandag briefing en zondag synthesize

### Established Patterns
- `registry.md`: skills worden aangeroepen als /commandos — zelfde mapping gebruiken voor Telegram NLP routing
- n8n draait op Proxmox Starfleet (Docker) — SSH Execute node is de standaard bridge naar host

### Integration Points
- Telegram: TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID al geconfigureerd (notification.sh)
- Slack: nieuwe workspace + bot token nodig (nog niet opgezet)
- Claude Code CLI: beschikbaar op Proxmox host, bereikbaar via n8n SSH node

</code_context>

<deferred>
## Deferred Ideas

Geen — discussie bleef binnen fase-scope.

</deferred>

---

*Phase: 02-core-skills*
*Context gathered: 2026-03-18*
