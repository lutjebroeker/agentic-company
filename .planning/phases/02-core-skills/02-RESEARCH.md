# Phase 2: Core Skills Live - Research

**Researched:** 2026-03-18
**Domain:** n8n workflow automation — Telegram/Slack listeners, SSH-to-CLI bridge, scheduled proactive workflows
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Phase Boundary:** Always-on chat interface via Telegram en Slack waarmee Jelle de 8 skills (ceo, marketing, sales, ops, personal, review, learn, ship) kan aanroepen via gewone berichten. Plus 3 proactieve n8n workflows die automatisch output sturen op vaste tijdstippen. Claude Code wordt aangeroepen via CLI, niet via directe Anthropic API (Jelle heeft Max abonnement, geen API key).

**Telegram routing:**
- Gewone zinnen, geen expliciete slash commands — bot herkent skill via NLP
- Bij ambiguïteit: terugvragen welke skill bedoeld wordt ("Bedoel je /ceo of /sales?")
- Thread-context: laatste 5 berichten meesturen als conversatie-context
- Stateless per sessie (geen langetermijn-geheugen buiten de 5 berichten)

**Slack kanaalmodel:**
- 5 dedicated kanalen: #agent-ceo, #agent-marketing, #agent-sales, #agent-ops, #agent-personal
- Skill wordt bepaald door kanaal — geen NLP routing nodig in Slack
- Bot reageert altijd in thread (kanaal blijft overzichtelijk)
- Alleen Jelle mag triggeren (user-ID whitelist in n8n)
- Thread-context: bot leest thread history voor vervolgvragen

**Claude aanroepen in n8n:**
- Claude Code CLI via SSH: n8n → Proxmox host → `claude -p "..."`
- n8n en Claude Code draaien op dezelfde Proxmox server (SSH toegang beschikbaar)
- Skill prompt als -p argument: `claude -p "$(cat ~/.claude/commands/{skill}.md)\n\nVraag: {user_message}"`
- Geen directe Anthropic API (vereist apart API account — Jelle heeft Max abonnement)

**Proactieve workflows:**

Maandag 07:00 — Content briefing:
- Input: learning/wins.md + fails.md + improvements.md van afgelopen week
- Verwerking: synthesize via /learn → gestructureerd briefing document
- Output: Telegram bericht (wat werkte, wat niet, welk verhaal zit daarin)
- Jelle beslist zelf wat content wordt en stuurt door naar Ziplined

Dagelijks 09:00 — DM-suggesties (#agent-sales):
- Input: memory/pipeline.md (opvolging op basis van laatste contact-datum) + LinkedIn signalen (likes/comments op posts)
- Output: Slack thread in #agent-sales met concrete DM-suggesties voor die dag

Zondag 18:00 — Wekelijkse /learn synthesize:
- Input: wins.md + fails.md + improvements.md van die week
- Output: Telegram bericht (wat werkte, wat niet, 1 aanpassing voor volgende week) + improvements.md automatisch bijgewerkt

### Claude's Discretion
- Exacte NLP routing-logica voor Telegram (welk model/prompt voor skill-detectie)
- LinkedIn signalen ophalen: specifieke API aanpak of scraping
- Format en lengte van Telegram berichten
- Error handling en retry-gedrag bij CLI timeout

### Deferred Ideas (OUT OF SCOPE)
Geen — discussie bleef binnen fase-scope.
</user_constraints>

---

## Summary

Phase 2 bouwt drie n8n workflow groepen: (1) een Telegram always-on listener die binnenkomende berichten via NLP routeert naar de juiste skill en Claude Code aanroept via SSH, (2) een Slack agent router die per kanaal de juiste skill aanroept, en (3) drie proactieve scheduled workflows die op vaste tijdstippen output pushen naar Telegram/Slack.

De centrale technische uitdaging is de SSH bridge naar Claude Code CLI. n8n op Proxmox roept via een SSH node `claude -p "..."` aan op de host. Dit is een bewezen patroon (gedocumenteerd door de community), maar kent twee kritieke valkuilen: (a) de SSH sessie laadt geen shell profile waardoor `claude` niet gevonden wordt tenzij je het volledige pad gebruikt, en (b) `claude -p` kan 10-60 seconden duren — ruim binnen de n8n default timeout van 3600 seconden maar vergt een workflow-level timeout instelling.

Voor Telegram gebruikt n8n de ingebouwde Telegram Trigger node (webhook-gebaseerd). De node registreert automatisch een webhook bij Telegram. Één kritieke beperking: Telegram staat maar één webhook per bot token toe — test- en productieomgeving moeten separate bots gebruiken. De Slack integratie vereist het aanmaken van een Slack App, bot token (xoxb-), en het configureren van OAuth scopes voor de Slack Trigger node (events API via webhook).

**Primary recommendation:** Bouw de drie plans sequentieel — eerst Telegram listener (bewezen simpelste stack), dan Slack (vereist Slack App setup), dan proactieve workflows (afhankelijk van werkende SSH bridge uit plans 02-01/02-02).

---

## Standard Stack

### Core
| Component | Version/Node | Purpose | Why Standard |
|-----------|-------------|---------|--------------|
| n8n Telegram Trigger | `n8n-nodes-base.telegramtrigger` | Webhook listener voor inkomende Telegram berichten | Ingebouwd, geen extra packages |
| n8n Telegram node | `n8n-nodes-base.telegram` | Antwoorden sturen via Telegram Bot API | Ingebouwd |
| n8n SSH node | `n8n-nodes-base.ssh` | `claude -p` uitvoeren op Proxmox host | Bridge naar Claude Code zonder API key |
| n8n Slack Trigger | `n8n-nodes-base.slacktrigger` | Events API webhook voor berichten in kanalen | Ingebouwd |
| n8n Slack node | `n8n-nodes-base.slack` | Thread replies sturen in Slack | Ingebouwd |
| n8n Schedule Trigger | `n8n-nodes-base.scheduletrigger` | Cron-gebaseerde triggers voor proactieve workflows | Ingebouwd |
| n8n Code node (JS) | `n8n-nodes-base.code` | NLP routing-logica, whitelist check, bericht formattering | Custom logic zonder externe packages |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| n8n IF node | Conditionals: whitelist check, ambiguity detection | Overal waar vertakking nodig is |
| n8n Switch node | Multi-skill routing op basis van kanaal of gedetecteerde intent | Alternatief voor IF-cascade |
| n8n Set node | Velden mappen en transformeren | Data prep voor SSH command string |
| n8n Read Binary File / SSH download | Skills/memory bestanden lezen als input | Proactieve workflows die bestanden inlezen |

### Alternatives Considered
| Standard | Alternative | Tradeoff |
|----------|-------------|----------|
| SSH node naar Claude Code CLI | n8n AI Agent node (Anthropic Claude) | AI Agent vereist Anthropic API key — Jelle heeft Max abonnement, geen aparte API key |
| Telegram Trigger (webhook) | Community polling node (`n8n-nodes-telegram-polling`) | Polling is trager en minder betrouwbaar; webhook is de standaard n8n benadering |
| Slack Events API (Trigger node) | Slack Slash Commands (webhook) | Slash commands vereisen explicit `/command` syntax — kanaal-gebaseerd model is schoner |

---

## Architecture Patterns

### Recommended Workflow Structure

```
n8n workflows:
├── 02-01-telegram-listener          # Telegram trigger → NLP routing → SSH → reply
├── 02-02-slack-agent-router         # Slack trigger → kanaal-routing → SSH → thread reply
├── 02-03a-content-briefing          # Schedule (maandag 07:00) → bestanden lezen → SSH → Telegram
├── 02-03b-dm-suggestions            # Schedule (dagelijks 09:00) → pipeline.md lezen → SSH → Slack
└── 02-03c-learn-synthesize          # Schedule (zondag 18:00) → bestanden lezen → SSH → Telegram + file write
```

### Pattern 1: Telegram Listener met NLP Skill Routing

**What:** Telegram Trigger ontvangt bericht → Code node detecteert skill via keyword/NLP matching → IF-ambiguity check → SSH node roept `claude -p` aan met juiste skill prompt → Telegram antwoord

**When to use:** Plan 02-01 — alle interactieve Telegram berichten

**Flow:**
```
Telegram Trigger
  → Code (extract message + chat_id + last 5 messages context)
  → Code (NLP skill detection: keywords → skill mapping)
  → IF (confident match?)
    ├─ [YES] SSH (claude -p "$(skill_prompt)\n\nContext: {last5}\n\nVraag: {message}")
    │       → Telegram (sendMessage, chat_id, response)
    └─ [NO]  Telegram (sendMessage: "Bedoel je /ceo of /sales?")
             → (wait for follow-up — stateless, volgende bericht triggert opnieuw)
```

**NLP routing aanpak (Claude's Discretion — aanbeveling):**

Gebruik keyword-matching in een Code node als eerste laag. Dit is sneller dan een aparte LLM-call en voldoende voor 80% van de gevallen. Keywords per skill:
```javascript
// Source: CONTEXT.md skills mapping + registry.md patterns
const skillKeywords = {
  ceo:        ['strategie', 'prioriteit', 'bottleneck', 'focus', 'besliss', 'hormozi'],
  marketing:  ['content', 'post', 'linkedin', 'schrijf', 'tekst', 'campagne'],
  sales:      ['lead', 'dm', 'outreach', 'klant', 'pipeline', 'drift', 'meet'],
  ops:        ['n8n', 'workflow', 'vps', 'server', 'automatiseer', 'deploy'],
  personal:   ['week', 'check', 'accountab', 'doel', '12wy', 'executie'],
  review:     ['review', 'feedback', 'beoordeel', 'trust formula', 'score'],
  learn:      ['leer', 'wins', 'fails', 'synthesize', 'verbetering'],
  ship:       ['publiceer', 'deploy', 'ship', 'push', 'verstuur']
};

// Als geen duidelijke match: ambiguity flag = true
```

### Pattern 2: Slack Kanaal-gebaseerde Routing

**What:** Slack Trigger ontvangt bericht in kanaal → IF check user-ID whitelist → skill bepaald door kanaal naam → SSH → thread reply in zelfde thread

**When to use:** Plan 02-02

**Flow:**
```
Slack Trigger (events: message.channels)
  → IF ($json.body.event.user === JELLE_USER_ID)
    ├─ [NOT JELLE] Stop (geen actie)
    └─ [IS JELLE]
       → Code (extract: channel_name, thread_ts, message_text, channel_id)
       → Code (channel → skill mapping:
                '#agent-ceo' → 'ceo',
                '#agent-marketing' → 'marketing', etc.)
       → SSH (claude -p "$(skill_prompt)\n\nVraag: {message}")
       → Slack (postMessage, channel_id, thread_ts, reply)
```

**Thread context ophalen:** Slack Trigger geeft `thread_ts` mee. Gebruik Slack node `getMessages` met `thread_ts` om thread history op te halen als context voor vervolgvragen.

### Pattern 3: SSH Bridge naar Claude Code

**What:** n8n SSH node voert `claude -p` uit op Proxmox host

**Critical configuration:**
```javascript
// SSH node command — gebruik altijd volledig pad
// Source: n8n community (SSH session laadt geen shell profile)
const command = `
  SKILL_PROMPT=$(cat /root/.claude/commands/${skill}.md)
  /usr/local/bin/claude --no-permissions-prompt -p "${SKILL_PROMPT}

Vraag: ${user_message}"
`
// NIET: claude -p (PATH niet geladen in SSH sessie)
// WEL: /usr/local/bin/claude -p (volledig pad)
```

**SSH credentials in n8n:** Host = Proxmox host IP, port 22, user = root (of de user waar Claude Code geinstalleerd is), private key authenticatie aanbevolen.

### Pattern 4: Proactieve Scheduled Workflows

**What:** Schedule Trigger op specifieke tijden → lees relevante bestanden via SSH cat commando → bouw prompt → SSH claude -p → stuur output naar Telegram/Slack

**When to use:** Plan 02-03

**Voorbeeld — Content Briefing (maandag 07:00):**
```
Schedule Trigger (cron: 0 7 * * 1, timezone: Europe/Amsterdam)
  → SSH (cat /root/projects/agentic-company/learning/wins.md
         /root/projects/agentic-company/learning/fails.md
         /root/projects/agentic-company/learning/improvements.md)
  → Code (combineer bestanden + bouw prompt)
  → SSH (claude -p "/learn synthesize\n\n{combined_content}")
  → Code (format als Telegram bericht, max 4096 chars)
  → Telegram (sendMessage)
```

### Anti-Patterns to Avoid

- **Shell profile niet geladen:** Gebruik altijd het volledige pad naar `claude` (`/usr/local/bin/claude` of via `which claude` vaststellen bij setup). Nooit alleen `claude` in SSH commands.
- **Eén Telegram bot voor test en productie:** Telegram staat slechts één webhook per bot token toe. Gebruik twee bots: één voor testen, één voor productie.
- **Slack token rotation ingeschakeld:** n8n credentials breken bij token rotation. Schakel dit uit in de Slack app settings.
- **Slack Thread TS vergeten:** Altijd `thread_ts` meegeven bij Slack replies zodat antwoorden in threads komen, niet in het kanaal.
- **Hardcoded user message in SSH command (injection risk):** Sanitize user input — geen raw message in de command string. Gebruik een tijdelijk bestand of escape de input correct.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Telegram webhook registratie | Custom webhook endpoint | n8n Telegram Trigger node | Beheert webhook lifecycle automatisch |
| Slack event subscriptions | Custom Slack bolt app | n8n Slack Trigger node | Ingebouwde events API integratie |
| Cron scheduler | Custom cron scripts op VPS | n8n Schedule Trigger | Betrouwbare scheduler met retry/error handling |
| Thread context ophalen | Eigen state management | Slack node `getMessages` + `thread_ts` | Ingebouwde Slack API call |
| Message length truncation | Custom parser | Code node met `.substring(0, 4096)` | Telegram max 4096 chars, Slack max 4000 chars |

**Key insight:** n8n heeft voor alle benodigde integraties (Telegram, Slack, SSH, Schedule) ingebouwde nodes. Er is geen externe code of packages nodig buiten n8n zelf.

---

## Common Pitfalls

### Pitfall 1: SSH — `claude: command not found`
**What goes wrong:** SSH node geeft "command not found" terwijl `claude` wel geïnstalleerd is.
**Why it happens:** SSH sessies in n8n laden geen login shell profile (`.bashrc`, `.profile`). `PATH` bevat niet `/usr/local/bin` of de node/npm directory.
**How to avoid:** Voer bij installatie `which claude` uit en gebruik het volledige pad in alle SSH commands. Voeg optioneel `export PATH=$PATH:/usr/local/bin` toe aan het begin van het command.
**Warning signs:** Command werkt via terminal maar niet via n8n SSH node.

### Pitfall 2: Telegram Webhook Conflict (test vs. productie)
**What goes wrong:** Workflow wisselen van test URL naar productie URL overschrijft de geregistreerde Telegram webhook. Berichten komen niet meer binnen.
**Why it happens:** Telegram staat maar één webhook URL per bot token toe.
**How to avoid:** Maak twee Telegram bots aan — één voor development (`@jelle_dev_bot`) en één voor productie (`@jelle_prod_bot`). Gebruik aparte credentials in n8n.
**Warning signs:** Na activeren van productie workflow reageert de bot niet meer op testberichten (en vice versa).

### Pitfall 3: Slack Signing Secret niet geconfigureerd
**What goes wrong:** Slack stopt met sturen van events of events worden genegeerd.
**Why it happens:** Vanaf n8n versie 1.106.0 verifieert de Slack Trigger node automatisch de Slack signature als `Signing Secret` geconfigureerd is. Zonder verificatie kan Slack besluiten onbetrouwbare endpoints te blacklisten.
**How to avoid:** Configureer altijd de Signing Secret in de n8n Slack credential naast het Bot Token.
**Warning signs:** Events komen sporadisch binnen, of Slack's Event Subscriptions pagina toont verificatiefouten.

### Pitfall 4: `claude -p` timeout bij lange prompts
**What goes wrong:** SSH node workflow faalt of hangt bij complexe skill aanroepen die langer dan enkele seconden duren.
**Why it happens:** Claude Code met complexe prompts en skill bestanden kan 10-30 seconden nodig hebben. n8n's default workflow timeout is ruim, maar de SSH node heeft ook een eigen connection timeout.
**How to avoid:** Configureer een ruime `EXECUTIONS_TIMEOUT` in n8n config (bijv. 300 seconden per workflow). Test eerst de verwachte responstijd van elke skill aanroep. Gebruik `--no-permissions-prompt` flag om interactieve prompts te voorkomen die de CLI doen hangen.
**Warning signs:** Workflow toont "timed out" error, of SSH node hangt indefinitely.

### Pitfall 5: User-ID whitelist vergeten in Slack workflow
**What goes wrong:** Andere Slack workspace leden (als die er zijn) of ongewenste bots kunnen de agent triggeren.
**Why it happens:** Slack Trigger node filtert niet automatisch op gebruiker.
**How to avoid:** Voeg altijd een IF node toe na de Slack Trigger die `$json.body.event.user` vergelijkt met Jelle's Slack User ID. IF false: stop workflow zonder actie.
**Warning signs:** Agent reageert op berichten van andere gebruikers.

### Pitfall 6: Slack Token Rotation
**What goes wrong:** n8n Slack credentials werken niet meer na verloop van tijd.
**Why it happens:** Slack token rotation verloopt automatisch na 12-24 uur bij bepaalde app configuraties.
**How to avoid:** Schakel "Token Rotation" uit in de Slack App settings (onder "OAuth & Permissions"). Gebruik long-lived Bot tokens voor n8n integraties.
**Warning signs:** Slack API calls geven 401 errors na eerder werkende integratie.

---

## Code Examples

### NLP Skill Detection (Code node)
```javascript
// Source: Pattern afgeleid van registry.md skill mapping
// Geplaatst in Code node na Telegram Trigger

const message = $json.body.message.text.toLowerCase();
const chatId = $json.body.message.chat.id;
const messageId = $json.body.message.message_id;

const skillKeywords = {
  ceo:        ['strategie', 'prioriteit', 'bottleneck', 'focus', 'besliss', 'hormozi', 'omzet'],
  marketing:  ['content', 'post', 'linkedin', 'schrijf', 'tekst', 'campagne', 'trust formula'],
  sales:      ['lead', 'dm', 'outreach', 'klant', 'pipeline', 'drift', 'meet', 'prospect'],
  ops:        ['n8n', 'workflow', 'vps', 'server', 'automatiseer', 'deploy', 'technisch'],
  personal:   ['week', 'check', 'accountab', 'doel', '12wy', 'executie', 'percentage'],
  review:     ['review', 'feedback', 'beoordeel', 'score'],
  learn:      ['leer', 'wins', 'fails', 'synthesize', 'verbetering', 'improvements'],
  ship:       ['publiceer', 'deploy', 'ship', 'push', 'verstuur', 'live']
};

let detectedSkill = null;
let maxMatches = 0;

for (const [skill, keywords] of Object.entries(skillKeywords)) {
  const matches = keywords.filter(kw => message.includes(kw)).length;
  if (matches > maxMatches) {
    maxMatches = matches;
    detectedSkill = skill;
  }
}

const confident = maxMatches >= 1;

return [{
  json: {
    chatId,
    messageId,
    originalMessage: $json.body.message.text,
    detectedSkill,
    confident,
    // Last 5 messages context wordt door n8n Window Buffer Memory of aparte Telegram getUpdates call opgehaald
  }
}];
```

### SSH Command Builder (Code node)
```javascript
// Source: Afgeleid van CONTEXT.md + n8n SSH community guidance (full path vereist)
// Geplaatst voor SSH node

const skill = $json.detectedSkill;
const userMessage = $json.originalMessage.replace(/"/g, '\\"'); // escape quotes
const skillPath = `/root/.claude/commands/${skill}.md`;

// Bouw het SSH command — gebruik volledig pad naar claude
const command = `
SKILL_PROMPT=$(cat ${skillPath})
/usr/local/bin/claude --no-permissions-prompt -p "$SKILL_PROMPT

Vraag: ${userMessage}"
`.trim();

return [{ json: { ...$json, sshCommand: command } }];
```

### Slack Thread Reply (Slack node config)
```javascript
// Resource: message, Operation: post
// Veld 'thread_ts' zorgt dat reply in thread komt
{
  "resource": "message",
  "operation": "post",
  "channel": "={{$json.channelId}}",
  "text": "={{$json.claudeResponse}}",
  "otherOptions": {
    "thread_ts": "={{$json.threadTs}}"
  }
}
```

### Schedule Trigger voor Proactieve Workflows
```javascript
// Maandag 07:00 — Content briefing
// Workflow settings timezone: Europe/Amsterdam
{
  "rule": {
    "interval": [
      {
        "field": "cronExpression",
        "expression": "0 7 * * 1"
      }
    ]
  }
}

// Dagelijks 09:00 — DM suggesties
// expression: "0 9 * * *"

// Zondag 18:00 — /learn synthesize
// expression: "0 18 * * 0"
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Telegram polling (getUpdates loop) | Telegram webhook (via n8n Trigger node) | Lagere latentie, geen polling overhead |
| Handmatige Slack API calls | n8n Slack Trigger + events API | Automatische webhook registratie |
| Directe Anthropic API voor LLM | Claude Code CLI via SSH | Geen API kosten, gebruikt bestaand Max abonnement |
| AI Agent node met LangChain memory | Stateless SSH call + conversatie context als prompt | Simpeler, geen externe dependencies |

**Relevant voor dit project:**
- n8n v1.106.0+: Slack Signing Secret verificatie ingebouwd in Trigger node
- Claude Code CLI: `--no-permissions-prompt` flag voorkomt interactieve prompts die CLI doen hangen
- Telegram: Eén webhook per bot token — productie en test bots apart houden

---

## LinkedIn Signalen (Claude's Discretion — Onderzoek)

De dagelijkse DM-suggesties workflow wil LinkedIn signalen (likes/comments) ophalen als input. Dit is een **open vraag** met beperkte opties:

**Optie A: Handmatig — LOW complexity, HIGH reliability**
Jelle voegt zelf LinkedIn engagement handmatig toe aan `memory/pipeline.md` als context voor de sales workflow. Geen API of scraping nodig. Aanbevolen voor MVP.

**Optie B: Phantombuster LinkedIn connector — MEDIUM complexity**
Phantombuster heeft een "LinkedIn Post Stats" phantom die likes/comments kan exporteren. Vereist Phantombuster account + LinkedIn sessie cookie. Gemiddeld betrouwbaar, kost ~$30/maand.

**Optie C: LinkedIn API — HIGH complexity, uncertain**
LinkedIn's official API vereist een bedrijfsaccount en goedkeuring voor marketing API. Niet realistisch voor persoonlijk gebruik.

**Aanbeveling (Claude's Discretion):** Start met Optie A (handmatig) voor MVP. Workflow leest `memory/pipeline.md` en geeft DM-suggesties op basis van stadium + laatste contactdatum. LinkedIn engagement als losse context die Jelle optioneel kan toevoegen aan pipeline.md notities.

---

## Open Questions

1. **Volledig pad naar `claude` op Proxmox host**
   - What we know: Claude Code is geïnstalleerd op Proxmox host, bereikbaar via SSH
   - What's unclear: Exact pad (`/usr/local/bin/claude`, `/root/.nvm/versions/node/vX/bin/claude`, etc.)
   - Recommendation: Eerste task van 02-01 is vaststellen van het pad via `which claude` of `find / -name claude -type f 2>/dev/null | head -5`

2. **Jelle's Slack User ID**
   - What we know: User-ID whitelist is vereist voor Slack workflow
   - What's unclear: Jelle's exacte Slack User ID (format: `U0123456789`)
   - Recommendation: Ophalen via Slack Admin → Profile → "Copy member ID"

3. **Telegram credentials status**
   - What we know: STATE.md meldt dat TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID nog niet ingesteld zijn (Phase 1 open item 01-05)
   - What's unclear: Of dit voor Phase 2 start geregeld is
   - Recommendation: Phase 2 kan niet starten zonder werkende Telegram bot. Plan 02-01 Wave 0 moet dit als prerequisite checken.

4. **Claude Code `--no-permissions-prompt` flag beschikbaarheid**
   - What we know: `claude -p` kan hangen bij interactieve prompts
   - What's unclear: Of de exacte flag naam correct is voor de versie op de Proxmox host
   - Recommendation: Test met `claude --help` via SSH node om beschikbare flags te zien

---

## Validation Architecture

Nyquist validation is uitgeschakeld in `.planning/config.json` (`workflow.nyquist_validation: false`). Deze sectie is overgeslagen.

---

## Sources

### Primary (HIGH confidence)
- n8n skills `/root/.claude/skills/n8n-workflow-patterns/` — webhook, scheduled, AI agent patterns
- n8n skills `/root/.claude/skills/n8n-node-configuration/` — node config patterns, Slack/HTTP node examples
- Project CONTEXT.md — locked decisions, existing assets, integration points

### Secondary (MEDIUM confidence)
- [n8n Telegram Trigger docs](https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.telegramtrigger/) — webhook setup, one webhook per bot token limitation
- [n8n Slack Trigger docs](https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.slacktrigger/) — events, channel watching, Signing Secret (v1.106.0+)
- [n8n Slack credentials docs](https://docs.n8n.io/integrations/builtin/credentials/slack/) — OAuth scopes: channels:read, chat:write, channels:history, groups:history, users:read
- [n8n Claude Code SSH guide](https://github.com/theNetworkChuck/n8n-claude-code-guide) — SSH node patterns voor Claude Code, full path requirement, permission flags
- [n8n community: Claude Code integration](https://community.n8n.io/t/claude-code-integration-for-n8n/244183) — SSH als eenvoudigste brug, Docker als alternatief

### Tertiary (LOW confidence)
- n8n community SSH timeout discussions — timeout configuratie per workflow (EXECUTIONS_TIMEOUT env var)
- WebSearch: Slack OAuth scopes vereist voor n8n Trigger (channels:read, groups:read, im:read, mpim:read, chat:write, *:history scopes)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — alle nodes zijn ingebouwd in n8n, patterns zijn gedocumenteerd
- Architecture: HIGH — flows zijn direct afgeleid van locked decisions + bewezen n8n patterns
- SSH bridge: MEDIUM — werkt bewezen in community, maar volledig pad vereist verificatie op productie host
- LinkedIn signalen: LOW — geen haalbare officiële API, handmatige aanpak aanbevolen voor MVP
- Pitfalls: HIGH — gebaseerd op officiële docs + community-gedocumenteerde issues

**Research date:** 2026-03-18
**Valid until:** 2026-04-18 (30 dagen — n8n en Telegram/Slack integrations zijn stabiel)
