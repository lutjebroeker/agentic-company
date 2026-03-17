#!/bin/bash
# sync.sh — Synchroniseer claude-config/ naar ~/.claude/
#
# Gebruik:
#   ./sync.sh          # Sync config naar ~/.claude/ (symlinks)
#   ./sync.sh --copy   # Kopieer bestanden i.p.v. symlinken
#   ./sync.sh --dry    # Toon wat er zou gebeuren zonder iets te doen
#   ./sync.sh --status # Toon huidige sync status
#
# Dit script maakt symlinks van ~/.claude/ naar deze repo,
# zodat wijzigingen in je config automatisch in git zitten.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
MODE="${1:-link}"

# Kleuren
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

# Bestanden die we beheren
declare -A FILES=(
    ["settings.json"]="settings.json"
    ["hooks/stop-hook-git-check.sh"]="stop-hook-git-check.sh"
    ["skills/session-start-hook/SKILL.md"]="skills/session-start-hook/SKILL.md"
)

# Commands directory — alles erin wordt gesynct
sync_commands() {
    local src="$SCRIPT_DIR/commands"
    local dst="$CLAUDE_DIR/commands"

    if [[ ! -d "$src" ]] || [[ -z "$(ls -A "$src" 2>/dev/null)" ]]; then
        return
    fi

    mkdir -p "$dst"
    for file in "$src"/*.md; do
        [[ -f "$file" ]] || continue
        local name=$(basename "$file")
        sync_file "commands/$name" "commands/$name"
    done
}

sync_file() {
    local repo_rel="$1"   # Relatief pad in claude-config/
    local claude_rel="$2" # Relatief pad in ~/.claude/
    local src="$SCRIPT_DIR/$repo_rel"
    local dst="$CLAUDE_DIR/$claude_rel"

    if [[ ! -f "$src" ]]; then
        warn "Bron niet gevonden: $repo_rel"
        return
    fi

    # Maak parent directory aan
    mkdir -p "$(dirname "$dst")"

    case "$MODE" in
        --dry)
            if [[ -L "$dst" ]]; then
                local current=$(readlink -f "$dst")
                if [[ "$current" == "$src" ]]; then
                    log "[OK] $claude_rel → $repo_rel"
                else
                    warn "[UPDATE] $claude_rel → $repo_rel (was: $current)"
                fi
            elif [[ -f "$dst" ]]; then
                warn "[REPLACE] $claude_rel (bestaand bestand wordt vervangen)"
            else
                log "[NEW] $claude_rel → $repo_rel"
            fi
            ;;
        --copy)
            cp "$src" "$dst"
            chmod --reference="$src" "$dst" 2>/dev/null || true
            log "Gekopieerd: $claude_rel"
            ;;
        --status)
            if [[ -L "$dst" ]]; then
                local current=$(readlink -f "$dst")
                if [[ "$current" == "$src" ]]; then
                    log "$claude_rel → gelinkt (in sync)"
                else
                    warn "$claude_rel → gelinkt naar ANDER bestand: $current"
                fi
            elif [[ -f "$dst" ]]; then
                if diff -q "$src" "$dst" >/dev/null 2>&1; then
                    log "$claude_rel → kopie (in sync)"
                else
                    warn "$claude_rel → kopie (VERSCHILT van repo)"
                fi
            else
                err "$claude_rel → ONTBREEKT"
            fi
            ;;
        *)
            # Default: symlink
            # Backup bestaand bestand als het geen symlink is
            if [[ -f "$dst" && ! -L "$dst" ]]; then
                local backup="$dst.backup.$(date +%s)"
                mv "$dst" "$backup"
                warn "Backup: $claude_rel → $(basename "$backup")"
            fi
            # Verwijder bestaande symlink
            [[ -L "$dst" ]] && rm "$dst"
            ln -s "$src" "$dst"
            log "Gelinkt: $claude_rel → $repo_rel"
            ;;
    esac
}

echo "Claude Config Sync"
echo "=================="
echo "Bron:  $SCRIPT_DIR"
echo "Doel:  $CLAUDE_DIR"
echo "Mode:  $MODE"
echo ""

mkdir -p "$CLAUDE_DIR"

# Sync individuele bestanden
for repo_rel in "${!FILES[@]}"; do
    claude_rel="${FILES[$repo_rel]}"
    sync_file "$repo_rel" "$claude_rel"
done

# Sync commands directory
sync_commands

echo ""
case "$MODE" in
    --dry)    echo "Dry run — geen wijzigingen gemaakt." ;;
    --status) echo "Status check compleet." ;;
    --copy)   echo "Bestanden gekopieerd naar $CLAUDE_DIR" ;;
    *)        echo "Symlinks aangemaakt. Wijzigingen in ~/.claude/ komen nu in git." ;;
esac
