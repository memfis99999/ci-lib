#!/bin/bash
CONF_DIR=".github/sync"
MIR_BR=${1:-$(cat $CONF_DIR/mirror-branch.txt 2>/dev/null || echo "upstream-mirror")}
TGT_BR=${2:-$(cat $CONF_DIR/target-branch.txt 2>/dev/null || echo "master")}

CAN_MERGE=false
# Ищем флаг в новой папке sync/
FILE="$CONF_DIR/auto-update.txt"
if [ -f "$FILE" ]; then
    VAL=$(grep -v '^#' "$FILE" | xargs | tr '[:upper:]' '[:lower:]')
    [[ "$VAL" =~ ^(true|1|on)$ ]] && CAN_MERGE=true
fi

if [ "$CAN_MERGE" = true ]; then
    git checkout "$TGT_BR"
    git merge "origin/$MIR_BR" --no-edit && git push origin "$TGT_BR"
    echo "merge_result=UPDATED"
else
    echo "merge_result=SKIPPED"
fi
