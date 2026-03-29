#!/bin/bash
# spawn-cluster.sh — Startet Worker-Sessions für Sprint-Cluster
#
# Nutzung:
#   bash spawn-cluster.sh <master-brief> <sprint-plan-1> [sprint-plan-2] ...
#
# Beispiel:
#   bash spawn-cluster.sh docs/sprints/myproject/master-brief.md \
#     docs/sprints/myproject/sprint-001.md \
#     docs/sprints/myproject/sprint-002.md \
#     docs/sprints/myproject/sprint-004.md
#
# Was passiert:
#   - Erstellt eine tmux-Session "sprint-cluster"
#   - Jeder Sprint-Plan bekommt ein eigenes tmux-Window mit einer Claude Code Instanz
#   - Jeder Worker arbeitet seinen Sprint autonom ab
#   - Workers koordinieren sich über claude-peers (list_peers, send_message)
#   - Das aufrufende Terminal bleibt Orchestrator
#
# Voraussetzungen:
#   - tmux installiert
#   - claude CLI verfügbar
#   - claude-peers MCP in .mcp.json konfiguriert

set -euo pipefail

# --- Args ---

if [ $# -lt 2 ]; then
  echo "Usage: spawn-cluster.sh <master-brief> <sprint-plan-1> [sprint-plan-2] ..."
  echo ""
  echo "Startet für jeden Sprint-Plan einen autonomen Claude Code Worker in tmux."
  exit 1
fi

MASTER_BRIEF="$1"
shift
SPRINT_PLANS=("$@")

# --- Validate ---

if [ ! -f "$MASTER_BRIEF" ]; then
  echo "ERROR: Master-Brief nicht gefunden: $MASTER_BRIEF"
  exit 1
fi

for plan in "${SPRINT_PLANS[@]}"; do
  if [ ! -f "$plan" ]; then
    echo "ERROR: Sprint-Plan nicht gefunden: $plan"
    exit 1
  fi
done

if ! command -v tmux &>/dev/null; then
  echo "ERROR: tmux ist nicht installiert. Installiere mit: apt install tmux"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "ERROR: claude CLI nicht gefunden"
  exit 1
fi

# --- Config ---

CLUSTER_ID="sprint-cluster-$(date +%Y%m%d-%H%M%S)"
WORKER_COUNT=${#SPRINT_PLANS[@]}
LOG_DIR="/tmp/${CLUSTER_ID}"
mkdir -p "$LOG_DIR"

# Allowed tools for workers — full autonomy for sprint execution
ALLOWED_TOOLS="Read,Edit,Write,Bash,Glob,Grep,Agent,Skill"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " SPRINT-CLUSTER WIRD GESTARTET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Cluster-ID:   $CLUSTER_ID"
echo " Master-Brief: $MASTER_BRIEF"
echo " Workers:      $WORKER_COUNT"
echo " Log-Dir:      $LOG_DIR"
echo ""

# --- Spawn Workers ---

# Erstelle tmux-Session mit erstem Worker
FIRST_PLAN="${SPRINT_PLANS[0]}"
FIRST_NAME="worker-1"
SPRINT_NUM=$(echo "$FIRST_PLAN" | grep -oP 'sprint-\K\d+' || echo "1")

PROMPT="Du bist ein Cluster-Worker in einem parallelen Sprint-Setup.

Lies diese beiden Dokumente:
1. Master-Brief: ${MASTER_BRIEF}
2. Sprint-Plan: ${FIRST_PLAN}

WICHTIG — Cluster-Worker-Protokoll:
- Setze sofort deine Summary via set_summary mit deinem Sprint-Ziel
- Arbeite den Sprint vollständig ab (subagent-driven-development)
- Nach jedem Task: commit + push + Summary aktualisieren
- Wenn du fertig bist: sende 'SPRINT_DONE:${SPRINT_NUM}' an alle Peers via send_message
- Wenn du blockiert bist: sende 'SPRINT_BLOCKED:${SPRINT_NUM}:Grund' an Peers
- Ändere NUR Dateien die zu deinem Sprint gehören
- Bei Konflikten mit anderen Workers: STOPPEN und SPRINT_BLOCKED melden

Starte jetzt. Lies zuerst beide Dokumente, dann arbeite los."

tmux new-session -d -s "$CLUSTER_ID" -n "$FIRST_NAME" \
  "claude -p '$(echo "$PROMPT" | sed "s/'/'\\\\''/g")' \
    --allowedTools '$ALLOWED_TOOLS' \
    --dangerously-skip-permissions \
    2>&1 | tee '${LOG_DIR}/${FIRST_NAME}.log'; \
    echo ''; echo 'Worker fertig. Enter zum Schließen.'; read"

echo " [1/$WORKER_COUNT] $FIRST_NAME → $(basename "$FIRST_PLAN") (tmux: $CLUSTER_ID:$FIRST_NAME)"

# Restliche Workers als neue tmux-Windows
for i in $(seq 1 $((WORKER_COUNT - 1))); do
  PLAN="${SPRINT_PLANS[$i]}"
  WORKER_NAME="worker-$((i + 1))"
  SPRINT_NUM=$(echo "$PLAN" | grep -oP 'sprint-\K\d+' || echo "$((i + 1))")

  PROMPT="Du bist ein Cluster-Worker in einem parallelen Sprint-Setup.

Lies diese beiden Dokumente:
1. Master-Brief: ${MASTER_BRIEF}
2. Sprint-Plan: ${PLAN}

WICHTIG — Cluster-Worker-Protokoll:
- Setze sofort deine Summary via set_summary mit deinem Sprint-Ziel
- Arbeite den Sprint vollständig ab (subagent-driven-development)
- Nach jedem Task: commit + push + Summary aktualisieren
- Wenn du fertig bist: sende 'SPRINT_DONE:${SPRINT_NUM}' an alle Peers via send_message
- Wenn du blockiert bist: sende 'SPRINT_BLOCKED:${SPRINT_NUM}:Grund' an Peers
- Ändere NUR Dateien die zu deinem Sprint gehören
- Bei Konflikten mit anderen Workers: STOPPEN und SPRINT_BLOCKED melden

Starte jetzt. Lies zuerst beide Dokumente, dann arbeite los."

  tmux new-window -t "$CLUSTER_ID" -n "$WORKER_NAME" \
    "claude -p '$(echo "$PROMPT" | sed "s/'/'\\\\''/g")' \
      --allowedTools '$ALLOWED_TOOLS' \
      --dangerously-skip-permissions \
      2>&1 | tee '${LOG_DIR}/${WORKER_NAME}.log'; \
      echo ''; echo 'Worker fertig. Enter zum Schließen.'; read"

  echo " [$((i + 1))/$WORKER_COUNT] $WORKER_NAME → $(basename "$PLAN") (tmux: $CLUSTER_ID:$WORKER_NAME)"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " CLUSTER LÄUFT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Befehle:"
echo "   tmux attach -t $CLUSTER_ID              # Cluster beobachten"
echo "   tmux select-window -t $CLUSTER_ID:worker-1  # Zu Worker 1 wechseln"
echo "   Ctrl+B, N                                # Nächstes Window"
echo "   Ctrl+B, P                                # Vorheriges Window"
echo ""
echo " Logs:"
for i in $(seq 1 $WORKER_COUNT); do
  echo "   ${LOG_DIR}/worker-${i}.log"
done
echo ""
echo " Dieses Terminal bleibt frei für Orchestrator-Aufgaben."
echo " Starte hier claude und nutze list_peers um die Worker zu überwachen."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
