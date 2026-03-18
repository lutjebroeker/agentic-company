# Registry — Wat is beschikbaar, waar, wanneer te gebruiken

## Eigen commands

| Command | Wanneer | Wat het doet |
|---|---|---|
| `/ceo` | Strategische keuzes, prioritering, "moet ik dit doen?" | Hormozi Value Equation, bottleneck, één actie |
| `/marketing` | LinkedIn post schrijven, content plannen | Priestley framework, Trust Formula gate, Nederlands |
| `/ops` | n8n workflow bouwen, VPS setup, technisch werk | Genereert valide workflow JSON, installatiescripts |
| `/sales` | Outreach, DMs, pipeline beheer | DRIFT/MEET pitch, temperatuurladder, referrals |
| `/review` | Kwaliteitscheck op content, offers, code | Trust Formula + Hormozi score, adversarieel, verdict |
| `/personal` | Executie check, accountability, 12WY | MEET-cyclus, confrontatie op data, één aanpassing |
| `/learn` | Kennis loggen, patronen analyseren, extern absorberen | Log wins/fails, synthesize, absorb URL/bestand |
| `/ship` | Publiceren, deployen, communiceren | Pre-ship checklist, Ziplined/n8n MCP, changelog |

## Content patterns

| Pattern | Pad | Wanneer |
|---|---|---|
| LinkedIn Pain | `patterns/content/linkedin-pain.md` | Post over probleem dat ICP herkent |
| LinkedIn Prize | `patterns/content/linkedin-prize.md` | Post over gewenst resultaat/aspiratie |
| LinkedIn News | `patterns/content/linkedin-news.md` | Commentaar op actueel nieuws vanuit eigen lens |

## Externe patterns (cherry-picked)

| Pattern | Pad | Wanneer |
|---|---|---|
| Extract Wisdom | `patterns/external/extract-wisdom.md` | Artikel/video → kernlessen en inzichten |
| Rate Content | `patterns/external/rate-content.md` | Content beoordelen + Trust Formula scoring |
| Improve Writing | `patterns/external/improve-writing.md` | Draft verbeteren in eigen stem |

## Memory bestanden

| Bestand | Inhoud | Geladen door |
|---|---|---|
| `memory/context.md` | Wie Jelle is, doelen, constraints, DRIFT/MEET | `/ceo`, `/marketing`, `/ops`, `/personal` |
| `memory/icp.md` | Ideale klantprofielen | `/marketing`, `/sales` |
| `memory/offer-stack.md` | Gold/Silver/Bronze producten + prijzen | `/ceo`, `/sales`, `/review` |
| `memory/pipeline.md` | Outreach pipeline status | `/sales` |

## Learning bestanden

| Bestand | Inhoud | Geschreven door |
|---|---|---|
| `learning/wins.md` | Patterns die resultaat gaven | `/learn log win`, `/ship` |
| `learning/fails.md` | Patterns die faalden | `/learn log fail` |
| `learning/improvements.md` | Pending verbeteringen | `/learn synthesize` |
| `learning/changelog.md` | Pattern updates + sessie logs | `/learn`, `/ship`, post-session hook |

## Hooks

| Hook | Wanneer | Wat het doet |
|---|---|---|
| `stop-hook-git-check.sh` | Elke sessie-einde | Blokkeert bij uncommitted/unpushed changes |
| `post-session.sh` | Elke sessie-einde | Auto-log naar learning/changelog.md |
| `notification.sh` | Bij `/ship` output | Stuurt naar Telegram (vereist TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID) |

## MCP servers

| Server | Wanneer | Voorbeeld |
|---|---|---|
| n8n MCP | Workflow bouwen, deployen, debuggen | "Maak een webhook workflow" |
| Ziplined MCP | LinkedIn post inplannen, brand voice | "Plan deze post in" |
| Supabase MCP | Database queries, Open Brain (toekomst) | "Sla dit op als vector" |
| Firecrawl MCP | Webpagina scrapen voor content input | "Lees dit artikel" |
| GitHub MCP | Repo beheer, issues, PRs | "Maak een issue aan" |
