# PRD Review — agentic-company vs. Repo

**Datum:** 18 maart 2026
**PRD versie:** Draft v1.0
**Repo:** `lutjebroeker/agentic-company` (main, commit `1367a4e`)

---

## Gebouwd en klaar

| PRD sectie | Status | Notities |
|---|---|---|
| §1-2 Probleem + doelen | n.v.t. | Context, geen deliverables |
| §4 Repo structuur | **Afwijking** | Bewust anders — zie onder |
| §5 Alle 8 commands | **Done** | ceo, marketing, sales, ops, personal, review, learn, ship |
| §6 Memory architectuur | **Done** | Tier 2 (memory/) + Tier 3 (learning/) aanwezig |
| §8 Hooks | **Deels** | post-session + notification gebouwd, pre-tool-use bewust geskipt |
| §10 IP-modellen | **Done** | DRIFT/MEET in memory/context.md |
| §11 Offer stack | **Done** | In memory/offer-stack.md |
| §14 CLAUDE.md | **Done** | Aangepast — laadt NIET alle memory bij start (bewuste keuze) |
| §12 Fase 0-3 | **Done** | Alles behalve Open Brain en beta testing |

---

## Bewuste afwijkingen van de PRD

| PRD zegt | Wij deden | Waarom |
|---|---|---|
| Commands in `.claude/commands/` | `claude-config/commands/` | Sync pattern — claude-config is source of truth |
| `pre-tool-use.sh` hook | Niet gebouwd | Gedragsregel in CLAUDE.md is effectiever en minder fragiel |
| `post-session.sh` vraagt interactief | Non-interactive auto-log | Hooks mogen niet interactief zijn |
| Altijd alle memory/ laden bij sessiestart | Commands laden wat ze nodig hebben | Voorkomt context bloat |
| Git submodules in `sources/` | Cherry-pick in `patterns/external/` | Geen submodule-overhead, alleen wat je gebruikt |
| `adapters/` directory | Niet gebouwd | Onnodig als je cherry-pickt i.p.v. submodules |

---

## Ontbrekend in de repo (PRD wel, repo niet)

| Item | PRD sectie | Status | Actie |
|---|---|---|---|
| Open Brain (Supabase + pgvector) | §7 | Manual action op board | Jij: Supabase project opzetten |
| `notification.sh` Telegram credentials | §8 | Gebouwd, niet actief | Jij: `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` instellen |
| `patterns/outreach/` (dm-warm, dm-engagement, dm-post-case) | §4 | Niet gebouwd | DM templates zitten in `/sales` command zelf |
| `patterns/analysis/` (trust-formula-score, drift-diagnosis, weekly-review) | §4 | Niet gebouwd | Logica zit in `/review` en `/personal` commands |
| `newsletter-edition.md` pattern | §4 | Niet gebouwd | Nog geen newsletter functionaliteit |
| `products/execution-engine/` (workflow-pack, obsidian-vault) | §4 | Niet gebouwd | Phase 4 — na beta testing |
| Onboarding video (Loom) | §12 | Niet gebouwd | Jij: opnemen na VPS template test |
| Wekelijkse `/learn synthesize` via n8n cron | §12 | Niet gebouwd | n8n workflow nodig |
| §13 n8n trigger map workflows | §13 | Niet gebouwd | n8n workflows — bouw via `/ops` |
| 7 van 10 Fabric patterns | §9 | Niet gebouwd | 3 cherry-picked, rest on-demand |

---

## Aanbeveling

### Niet bouwen (overkill nu)
- `patterns/outreach/` en `patterns/analysis/` — de logica zit al in de commands
- Alle 10 Fabric patterns — 3 is genoeg, voeg toe als je ze mist
- `adapters/` — niet nodig zonder submodules

### Wel toevoegen als issues (Manual action)
- Telegram credentials instellen
- n8n cron workflow voor wekelijkse `/learn synthesize`
- Onboarding video opnemen

### Pas bouwen bij eerste klant
- `products/execution-engine/` directory
- Newsletter pattern

---

## Project board status

| Status | Item |
|---|---|
| Manual action | Open Brain — Supabase + pgvector integratie |
| Manual action | Beta testing + case study publiceren |
| Done | /learn command — log/synthesize/absorb |
| Done | post-session.sh hook — non-interactive auto-logging |
| Done | notification.sh hook — Telegram doorsturen |
| Done | /personal command — 12WY + MEET cyclus |
| Done | /sales command — DRIFT/MEET + outreach |
| Done | /review command — kwaliteitscheck |
| Done | /ship command — publiceren + deployen |
| Done | Cherry-pick Fabric patterns naar patterns/external/ |
| Done | VPS template product — setup.sh + documentatie |

---

## Succescriteria check (PRD §16)

| Criterium | Status |
|---|---|
| CLAUDE.md geladen en werkend | **Done** — laadt bij elke sessie met correcte context |
| Vier core skills werkend | **Done** — alle 8 gebouwd |
| Learning loop actief | **Klaar voor gebruik** — /learn command + learning/ bestanden aanwezig |
| Open Brain gevuld | **Open** — Supabase setup nodig (manual action) |
| VPS template werkend | **Gebouwd** — test op schone Hetzner VM nodig (manual action) |
| Eerste beta-klant | **Open** — manual action |
| Case study gepubliceerd | **Open** — na beta-klant |
