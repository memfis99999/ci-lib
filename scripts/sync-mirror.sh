#!/bin/bash
set -euo pipefail

CONF_DIR=".github/sync"
URL=${1:-$(cat "$CONF_DIR/upstream-url.txt" 2>/dev/null)}
UP_BR=${2:-$(cat "$CONF_DIR/upstream-branch.txt" 2>/dev/null || echo "master")}
MIR_BR=${3:-$(cat "$CONF_DIR/mirror-branch.txt" 2>/dev/null || echo "upstream-mirror")}

# Логи — в stderr, чтобы не ломать GITHUB_OUTPUT
log() { echo "$@" >&2; }

git remote add upstream "$URL" 2>/dev/null || git remote set-url upstream "$URL"
git fetch upstream "$UP_BR" --tags --prune >&2

UP_HASH=$(git rev-parse "upstream/$UP_BR")
MIR_HASH=$(git rev-parse "origin/$MIR_BR" 2>/dev/null || echo "none")

if [ "$UP_HASH" = "$MIR_HASH" ]; then
  echo "changed=false"
  echo "critical=false"
  echo "hash=$(git rev-parse --short "$UP_HASH")"
  exit 0
fi

# --- ЛОГИКА СТОП-КРАНА ---
CRITICAL=false
CRIT_LIST=""
RULES_FILE="$CONF_DIR/critical-rules.txt"

if [ -f "$RULES_FILE" ] && [ "$MIR_HASH" != "none" ]; then
  CHANGED_FILES=$(git diff --name-only "$MIR_HASH" "$UP_HASH" || true)
  MATCHES=$(echo "$CHANGED_FILES" | grep -Ff "$RULES_FILE" || true)
  if [ -n "$MATCHES" ]; then
    CRITICAL=true
    CRIT_LIST=$(echo "$MATCHES" | head -n 3 | xargs)
  fi
fi

echo "critical=$CRITICAL"
echo "critical_list=$CRIT_LIST"
# --- КОНЕЦ ЛОГИКИ ---

# Важно: checkout/push шумят — уводим в stderr или делаем -q
git checkout -q "$MIR_BR" 2>/dev/null || git checkout -q -b "$MIR_BR" >&2
git reset --hard "$UP_HASH" >&2
git push -q origin "$MIR_BR" --force >&2

echo "changed=true"
echo "hash=$(git rev-parse --short "$UP_HASH")"
