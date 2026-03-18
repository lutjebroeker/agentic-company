# agentic-company — Personal AI Infrastructure

## Wie ik ben
Jelle Spek. Product Owner bij Enza Zaden (dagtaak).
Side business: Execution Engine + Logisch (met Daan).
Doel: €4.500/maand side income voor ik fulltime ga.
Tijdslimiet: 8–12 uur per week beschikbaar.
Tijdlijn: Juni 1 2026 = Execution Engine launch.

## Dit systeem
agentic-company is mijn persoonlijke AI-infrastructuur. Het combineert externe kennisbronnen met eigen IP (DRIFT/MEET) en verkoopbare producten. De repo structuur:

- `memory/` — statische business context (wie, wat, voor wie, waarvoor)
- `patterns/` — content templates en cherry-picked externe patterns
- `learning/` — zelflerend geheugen (wins, fails, improvements)
- `claude-config/` — sync source voor `~/.claude/` (commands, hooks, settings)
- `registry.md` — index van alle beschikbare tools en wanneer ze te gebruiken

## Commands
- `/ceo` — Hormozi strategie, bottleneck-denken, één actie per sessie
- `/marketing` — Priestley + Trust Formula content, altijd Nederlands
- `/ops` — n8n workflow generator, VPS setup, technische orkestratie
- `/sales` — DRIFT/MEET outreach, temperatuurladder, pipeline beheer
- `/review` — adversariële kwaliteitscheck, Trust Formula + Hormozi scoring
- `/personal` — 12WY accountability, MEET-cyclus, executie-percentages
- `/learn` — log wins/fails, synthesize patronen, absorb externe bronnen
- `/ship` — publiceren + deployen via Ziplined/n8n MCP

## Gedragsregels
1. Check `registry.md` als je twijfelt welk tool of pattern te gebruiken
2. Schrijf content altijd in het Nederlands tenzij anders gevraagd
3. Elke content output: Trust Formula score berekenen `(PCP + US) × (CC + PW)` — minimum 36/100
4. Bij twijfel over prioriteit: gebruik `/ceo`
5. Laad memory/ bestanden alleen wanneer een command ze nodig heeft — niet standaard

## Sync
Dit is een portable config repo. `claude-config/` is source of truth:
```bash
cd claude-config && ./sync.sh        # Symlink naar ~/.claude/
cd claude-config && ./sync.sh --dry  # Preview
```

## MCP servers
- n8n: workflow automation (Starfleet op Proxmox)
- Ziplined: LinkedIn brand voice
- Slack, Google Calendar, Gmail, Figma, Canva, Supabase, Vercel
