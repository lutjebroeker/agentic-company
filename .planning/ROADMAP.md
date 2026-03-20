# Roadmap: Agentic Company — Execution Engine

## Overview

Van werkende AI-infrastructuur naar eerste betalende klant en €4.500/maand side income. Fase 0 is grotendeels klaar — de repo staat, alle skills werken. De komende fases bouwen de always-on laag (Telegram/Slack agents), het semantisch geheugen (Open Brain), het eerste klanttraject (beta + case study) en de IP-distributie (DRIFT/MEET reeks + Execution Log).

## Milestones

- 🚧 **v1.0 Launch** — Phases 1–5 (target: 1 juni 2026)

## Phases

- [x] **Phase 1: Foundation** — Repo, skills, memory, hooks klaar ✅
- [ ] **Phase 2: Core Skills Live** — Always-on Telegram/Slack + proactieve n8n workflows
- [ ] **Phase 3: Memory & Intelligence** — Open Brain, Tone of Voice, Signal Agent, NuggetHunter
- [ ] **Phase 4: Eerste Klant** — VPS testen, beta-klant, case study machine
- [ ] **Phase 5: Distributie & IP** — DRIFT+MEET reeks, Execution Log, cold outreach systeem

## Phase Details

### Phase 1: Foundation ✅ COMPLETE
**Goal**: Repo structuur, alle 8 skills, memory architectuur, hooks, VPS template
**Status**: Grotendeels klaar bij GSD initialisatie (brownfield)

Completed:
- [x] 01-01: Repo structuur + CLAUDE.md + registry.md
- [x] 01-02: Alle 8 skills (ceo, marketing, sales, ops, personal, review, learn, ship)
- [x] 01-03: memory/ bestanden + learning/ map + hooks
- [x] 01-04: VPS template setup.sh + Fabric patterns

Remaining (Fase 0 open items):
- [ ] 01-05: Telegram credentials instellen (TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID)
- [ ] 01-06: memory/ bestanden completeren en actueel maken (icp, pipeline, offer-stack, context)

---

### Phase 2: Core Skills Live
**Goal**: Always-on agent interface via Telegram en Slack, plus drie proactieve n8n workflows actief
**Depends on**: Phase 1
**Success Criteria** (what must be TRUE):
  1. Telegram bericht sturen → antwoord binnen 10 seconden
  2. Slack #agent-ceo/marketing/sales/ops/personal → thread reply met juiste skill
  3. Maandag 07:00 → content briefing aankomt in Telegram
  4. Dagelijks 09:00 → DM-suggesties in Slack #agent-sales
  5. Zondag 18:00 → /learn synthesize output in Telegram + improvements.md bijgewerkt
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md — Telegram always-on listener (n8n workflow UVTUSH8NmMun11hY actief, wacht op human-verify)
- [ ] 02-02-PLAN.md — Slack workspace + agent router (5 kanalen, kanaal=skill, thread replies)
- [ ] 02-03-PLAN.md — Proactieve workflows (content briefing + DM-suggesties + /learn synthesize)

---

### Phase 3: Memory & Intelligence
**Goal**: Semantisch geheugen actief (Open Brain), schrijfstijl profiel gebouwd, Signal Agent + NuggetHunter draaien
**Depends on**: Phase 2
**Success Criteria** (what must be TRUE):
  1. capture_thought slaat gedachte op, semantisch zoeken vindt het terug
  2. /marketing genereert post die klinkt als Jelle (tone-of-voice.md actief)
  3. Audio via Telegram → Obsidian notitie + acties binnen 2 minuten
  4. Dagelijks nieuwe Intelligence notitie in Obsidian /Intelligence/
  5. Minimaal 20 gedachten in Open Brain na eerste week
**Plans**: 4 plans

Plans:
- [ ] 03-01: Open Brain setup (Supabase Cloud + pgvector + MCP + memory migratie)
- [ ] 03-02: Tone of Voice Guide (n8n workflow → memory/tone-of-voice.md)
- [ ] 03-03: Signal Agent (audio → Whisper → Obsidian + acties + debrief)
- [ ] 03-04: NuggetHunter Intelligence Engine (RSS → filter → Obsidian /Intelligence/)

---

### Phase 4: Eerste Klant
**Goal**: VPS template getest, eerste beta-klant actief, before/after executie-% gedocumenteerd, case study + 12 posts gepland
**Depends on**: Phase 2 (Slack agent-sales actief)
**Success Criteria** (what must be TRUE):
  1. setup.sh draait foutloos op schone Hetzner CAX11 + Loom video klaar
  2. Iemand anders gebruikt het systeem actief (dagelijkse check-ins)
  3. Week 4 executie-% gemeten en testimonial ontvangen
  4. 12 post drafts gepland in Ziplined (Trust Formula ≥ 36 per post)
  5. memory/case-study-1.md bestaat
**Plans**: 3 plans

Plans:
- [ ] 04-01: VPS template testen + Loom video (schone Hetzner CAX11)
- [ ] 04-02: Beta-klant benaderen + intake + 4-weken traject begeleiden
- [ ] 04-03: Case study machine — 12 posts draften + inplannen in Ziplined

---

### Phase 5: Distributie & IP
**Goal**: DRIFT+MEET als LinkedIn IP-reeks gepubliceerd, De Execution Log actief, cold outreach systeem draait, eerste betalende klant
**Depends on**: Phase 4
**Success Criteria** (what must be TRUE):
  1. 11 posts (DRIFT+MEET reeksen) gepland in Ziplined
  2. SVG assets in assets/ip-models/ in repo
  3. De Execution Log editie 1 gepubliceerd, minimaal 3 edities gepland
  4. pipeline.md heeft minimaal 5 actieve leads bijgehouden
  5. Eerste betalende Gold klant (€1.497) gesloten
**Plans**: 3 plans

Plans:
- [ ] 05-01: DRIFT+MEET reeks (SVG assets + 11 posts plannen in Ziplined)
- [ ] 05-02: De Execution Log nieuwsbrief (LinkedIn aanmaken + editie 1 + 3 edities plannen)
- [ ] 05-03: Cold outreach systeem (temperatuurladder + Obsidian pipeline + n8n updater)

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 4/6 | Partial (brownfield) | 2026-03-18 |
| 2. Core Skills Live | 1/3 | In progress | - |
| 3. Memory & Intelligence | 0/4 | Not started | - |
| 4. Eerste Klant | 0/3 | Not started | - |
| 5. Distributie & IP | 0/3 | Not started | - |
