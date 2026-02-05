#!/bin/bash
# params: MIRROR_NAME, TARGET_NAME
MIR_BR=$1; TGT_BR=$2

CAN_MERGE=false
FILE=".github/auto-update-default.txt"
if [ -f "$FILE" ]; then
    VAL=$(grep -v '^#' "$FILE" | grep -v '^[[:space:]]*$' | head -n 1 | xargs | tr '[:upper:]' '[:lower:]')
    [[ "$VAL" =~ ^(true|1|on)$ ]] && CAN_MERGE=true
fi

if [ "$CAN_MERGE" = true ]; then
    git checkout "$TGT_BR"
    git merge "origin/$MIR_BR" --no-edit && git push origin "$TGT_BR"
    echo "merge_result=UPDATED"
else
    echo "merge_result=SKIPPED"
fi
