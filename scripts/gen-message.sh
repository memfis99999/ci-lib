#!/bin/bash
REPO=$1; BR=$2; STATUS=$3; HASH=$4; RID=$5; CRIT_LIST=$6

echo "<b>Repo:</b> $REPO"
echo "<b>Branch:</b> $BR"

if [ "$STATUS" == "BLOCKED_CRITICAL" ]; then
    echo "<b>Result:</b> ⚠️ <b>MANUAL REVIEW REQUIRED</b>"
    echo "<b>Reason:</b> Critical core files changed (Makefile, Kconfig or src/)."
    [ -n "$CRIT_LIST" ] && echo "<b>Files:</b> $CRIT_LIST ..."
else
    echo "<b>Result:</b> $STATUS"
fi

[ -n "$HASH" ] && echo "<b>Upstream:</b> $HASH"

# Список коммитов
COMMITS=$(git log "origin/$BR..origin/upstream-mirror" --oneline --no-merges 2>/dev/null | head -n 5 | sed 's/^/- /')
if [ -n "$COMMITS" ]; then
    echo -e "\n<b>What's new:</b>\n$COMMITS"
fi

[ -n "$RID" ] && [ "$RID" != "0" ] && echo -e "\n<b>Run:</b> https://github.com/$REPO/actions/runs/$RID"
