#!/bin/bash
# Приоритет: Аргумент -> Файл -> Дефолт
MIR_BR=${1:-$(cat .github/sync/mirror-branch.txt 2>/dev/null || echo "upstream-mirror")}
TGT_BR=${2:-$(cat .github/sync/target-branch.txt 2>/dev/null || echo "master")}

CAN_MERGE=false
FILE=".github/auto-update-default.txt"
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
