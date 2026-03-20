---
phase: 02-core-skills
plan: "01"
subsystem: infra
tags: [n8n, telegram, ssh, claude-cli, nlp, workflow-automation]

# Dependency graph
requires: []
provides:
  - "n8n workflow 02-01-telegram-listener (active, ID: UVTUSH8NmMun11hY)"
  - "Telegram → NLP routing → SSH Claude CLI → Telegram reply pipeline"
  - "Chat ID whitelist enforcement (only Jelle's chat: 6897758158)"
affects: [02-02, 02-03]

# Tech tracking
tech-stack:
  added: [n8n Telegram Trigger, n8n SSH node, n8n Code node (JavaScript NLP)]
  patterns:
    - "Skill detection via keyword frequency scoring with tie-breaking"
    - "SSH bridge pattern: n8n → Proxmox SSH → claude --no-permissions-prompt -p"
    - "Chat ID whitelist at NLP node (early return for non-whitelisted senders)"

key-files:
  created:
    - ".planning/phases/02-core-skills/02-01-workflow-snapshot.json"
  modified: []

key-decisions:
  - "Claude CLI path /usr/bin/claude confirmed by user (not /usr/local/bin/claude as assumed in plan)"
  - "Chat ID whitelist 6897758158 implemented in NLP Code node (not in IF node) for early rejection"
  - "n8n credential name matching auto-resolves IDs — PLACEHOLDER strategy worked"
  - "SSH credential type: sshPassword (ID: OdKR4WxKZwBUMzZ5, name: SSH Claude Code)"
  - "Telegram credential: tdPo6KEDWQhIieb9 (Jelle's Exec Bot)"

patterns-established:
  - "n8n workflow reference snapshots stored in .planning/phases/XX/XX-YY-workflow-snapshot.json"
  - "Skill routing: keyword frequency scoring, confident = maxMatches >= 1 && !tie"

requirements-completed: [CORE-01]

# Metrics
duration: 33min
completed: 2026-03-20
---

# Phase 2 Plan 01: Telegram Listener Summary

**Always-on n8n workflow routing Dutch Telegram messages to 8 Claude skill prompts via keyword NLP + SSH bridge, with chat ID whitelist and ambiguity terugvraag**

## Performance

- **Duration:** 33 min
- **Started:** 2026-03-20T09:29:29Z
- **Completed:** 2026-03-20T10:03:24Z
- **Tasks:** 2 of 3 (Task 3 = checkpoint:human-verify, presented to user)
- **Files modified:** 1

## Accomplishments

- n8n workflow "02-01-telegram-listener" created and activated (ID: UVTUSH8NmMun11hY)
- 8-node pipeline: Telegram Trigger → NLP Code → IF branch → SSH Command builder → SSH Claude → Format → Telegram reply
- Chat ID whitelist (6897758158) blocks non-Jelle senders at NLP stage
- Ambiguity terugvraag via FALSE branch of IF node (no Claude call wasted)
- Credential auto-resolution: n8n matched "Jelle's Exec Bot" by name, resolved to ID tdPo6KEDWQhIieb9

## Task Commits

1. **Task 1: Prerequisites** - human-action checkpoint (completed by user before this session)
2. **Task 2: Build n8n workflow** - `381284e` (feat)
3. **Task 3: Verify end-to-end** - checkpoint:human-verify (presented to user)

**Plan metadata:** pending final commit

## Files Created/Modified

- `.planning/phases/02-core-skills/02-01-workflow-snapshot.json` - Workflow reference (ID, URL, credential IDs, node names)

## Decisions Made

- Claude CLI path is `/usr/bin/claude` (user confirmed, plan had `/usr/local/bin/claude` as example)
- Whitelist implemented in NLP Code node as early return (`if (chatId !== ALLOWED_CHAT_ID) return []`) — cleaner than a separate IF node
- Used credential name-only approach for "Jelle's Exec Bot"; n8n resolved to real ID automatically
- SSH credential type is `sshPassword` (matching existing "SSH Claude Code" credential)

## Deviations from Plan

**1. [Rule 1 - Bug] Claude CLI path corrected from plan example to user-confirmed value**
- **Found during:** Task 2 (building SSH command node)
- **Issue:** Plan showed `/usr/local/bin/claude` as example path; user confirmed actual path is `/usr/bin/claude`
- **Fix:** Used `/usr/bin/claude` in the SSH command builder Code node
- **Files modified:** n8n workflow (node 4: Code: Bouw SSH command)
- **Committed in:** 381284e (Task 2 commit)

**2. [Rule 2 - Missing Critical] Chat ID whitelist added to NLP node**
- **Found during:** Task 2 (building NLP Code node)
- **Issue:** CONTEXT.md specified "Alleen Jelle mag triggeren" but plan's NLP code didn't include whitelist enforcement
- **Fix:** Added `if (chatId !== ALLOWED_CHAT_ID) return []` early in NLP Code node with `ALLOWED_CHAT_ID = 6897758158`
- **Files modified:** n8n workflow (node 2: Code: Extract + NLP)
- **Committed in:** 381284e (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 bug fix, 1 missing critical security)
**Impact on plan:** Both necessary — wrong CLI path would break all executions, missing whitelist would expose Claude to any Telegram user.

## Issues Encountered

- n8n credentials API (GET /api/v1/credentials) returns "GET method not allowed" — credential IDs not discoverable via API. Resolved by using credential name-only in workflow creation; n8n auto-resolves names to IDs on activation.
- SSH to Proxmox (192.168.1.124) not accessible from this machine (permission denied) — no impact, n8n handles SSH itself.

## Next Phase Readiness

- Workflow is live at https://n8n.jellespek.nl/workflow/UVTUSH8NmMun11hY
- Awaiting human end-to-end verification (Task 3 checkpoint)
- After verification: Phase 02-02 (Slack listener) can proceed
- Blocker resolved: Telegram credential + SSH credential + Claude CLI path all confirmed

---
*Phase: 02-core-skills*
*Completed: 2026-03-20*
