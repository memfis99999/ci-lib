#!/bin/bash
MIR_BR=$1; TGT_BR=$2; IS_CRITICAL=$3
CONF_DIR=".github/sync"

CAN_MERGE=false
if [ "$IS_CRITICAL" == "true" ]; then
    echo "merge_result=BLOCKED_CRITICAL"
    exit 0
fi

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
