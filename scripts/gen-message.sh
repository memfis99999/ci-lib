#!/bin/bash
# params: REPO, BRANCH, STATUS, HASH, RUN_ID, SERVER_URL
REPO=$1; BR=$2; STATUS=$3; HASH=$4; RID=$5; S_URL=$6

# Собираем список коммитов (если статус не ошибка и не пропуск)
COMMITS=""
if [[ "$STATUS" != "SKIPPED" && "$STATUS" != *"ERROR"* ]]; then
    # Список последних 5 коммитов
    COMMITS=$(git log -n 5 --oneline --no-merges | sed 's/^/- /')
fi

echo "<b>Repo:</b> $REPO"
echo "<b>Branch:</b> $BR"
echo "<b>Result:</b> $STATUS"
[ -n "$HASH" ] && echo "<b>Upstream:</b> $HASH"
if [ -n "$COMMITS" ]; then
    echo ""
    echo "<b>What's new:</b>"
    echo "$COMMITS"
fi
echo ""
echo "<b>Run:</b> $S_URL/$REPO/actions/runs/$RID"
