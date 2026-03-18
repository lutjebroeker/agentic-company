# agentic-company

Persoonlijke AI-infrastructuur voor Execution Engine + Logisch. Modulair systeem met Claude Code commands, content patterns, en business context — draait op elke Proxmox VM/LXC.

## Quickstart

```bash
# 1. Clone de repo
git clone git@github.com:lutjebroeker/agentic-company.git
cd agentic-company

# 2. Sync config naar ~/.claude/
cd claude-config
./sync.sh

# 3. Start Claude Code in de repo root
cd ..
claude
```

Na sync zijn de commands direct beschikbaar als slash commands.

## Commands

| Command | Wat het doet | Voorbeeld |
|---|---|---|
| `/ceo` | Strategisch advies via Hormozi Value Equation | `/ceo Moet ik focussen op content of VPS template?` |
| `/marketing` | LinkedIn post schrijven (Priestley + Trust Formula) | `/marketing Schrijf een post over het execution gap` |
| `/ops` | n8n workflows bouwen, VPS setup scripts | `/ops Maak een webhook-naar-Telegram workflow` |

## Repo structuur

```
agentic-company/
├── CLAUDE.md                 # Master context — geladen bij elke sessie
├── registry.md               # Index: wat is beschikbaar, wanneer te gebruiken
├── claude-config/            # Source of truth → synct naar ~/.claude/
│   ├── commands/             # Slash commands (/ceo, /marketing, /ops)
│   ├── hooks/                # Stop hook (git check)
│   ├── skills/               # Session start hook
│   ├── settings.json         # Hooks + permissions
│   └── sync.sh               # Sync script
├── memory/                   # Business context
│   ├── context.md            # Wie, doelen, DRIFT/MEET modellen
│   ├── icp.md                # Ideale klantprofielen
│   ├── offer-stack.md        # Gold/Silver/Bronze producten
│   └── pipeline.md           # Outreach pipeline
├── patterns/                 # Content templates
│   └── content/              # LinkedIn pain/prize/news formats
└── learning/                 # Zelflerend geheugen
    ├── wins.md               # Wat werkte
    ├── fails.md              # Wat niet werkte
    ├── improvements.md       # Pending verbeteringen
    └── changelog.md          # Pattern update log
```

## Sync

De sync script linkt `claude-config/` naar `~/.claude/` zodat edits in de repo automatisch in git zitten.

```bash
cd claude-config
./sync.sh           # Symlink (default)
./sync.sh --copy    # Kopieer i.p.v. symlink
./sync.sh --dry     # Preview zonder wijzigingen
./sync.sh --status  # Toon huidige sync status
```

Nieuwe commands toevoegen: drop een `.md` in `claude-config/commands/` en run `./sync.sh`.

## Hoe het werkt

1. **CLAUDE.md** laadt bij elke sessie — geeft Claude de basiscontext
2. **Commands** laden specifieke memory-bestanden on demand (niet alles vooraf)
3. **Patterns** geven templates voor content — commands verwijzen ernaar
4. **Learning** groeit over tijd via wins/fails logging (handmatig nu, automatisch later)

## Roadmap

- [x] Phase 0: Foundation (CLAUDE.md, registry, memory, learning)
- [x] Phase 1: Core commands (/ceo, /marketing, /ops) + content patterns
- [ ] Phase 2: /learn command, post-session hook, Open Brain, /personal
- [ ] Phase 3: /sales, /review, /ship, Fabric patterns
- [ ] Phase 4: VPS template product, klant-documentatie
