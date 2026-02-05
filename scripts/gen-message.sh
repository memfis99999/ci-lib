#!/bin/bash
# Пытаемся взять данные из конфигов, если не переданы
REPO=${1:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "repo")")}
TGT_BR=${2:-$(cat .github/sync/target-branch.txt 2>/dev/null || echo "master")}
STATUS=${3:-"INFO"}
HASH=$4
RID=$5

# Для списка коммитов используем зеркало и таргет из файлов
MIR_BR=$(cat .github/sync/mirror-branch.txt 2>/dev/null || echo "upstream-mirror")

COMMITS=$(git log "origin/$TGT_BR..origin/$MIR_BR" --oneline --no-merges 2>/dev/null | head -n 5 | sed 's/^/- /')

echo "<b>Repo:</b> $REPO"
echo "<b>Branch:</b> $TGT_BR"
echo "<b>Result:</b> $STATUS"
[ -n "$HASH" ] && echo "<b>Upstream:</b> $HASH"
if [ -n "$COMMITS" ]; then
    echo -e "\n<b>What's new:</b>\n$COMMITS"
fi
[ -n "$RID" ] && [ "$RID" != "0" ] && echo -e "\n<b>Run:</b> https://github.com/$REPO/actions/runs/$RID"
