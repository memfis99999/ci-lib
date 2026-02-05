#!/bin/bash
# Params: UPSTREAM_URL, UPSTREAM_BRANCH, MIRROR_BRANCH, TARGET_BRANCH
URL=$1; UP_BR=$2; MIR_BR=$3; TGT_BR=$4

echo "Checking $URL..."

git remote add upstream "$URL" 2>/dev/null || git remote set-url upstream "$URL"
git fetch upstream "$UP_BR" --tags --prune

UP_HASH=$(git rev-parse upstream/"$UP_BR")
LOC_HASH=$(git rev-parse origin/"$MIR_BR" 2>/dev/null || echo "none")

if [ "$UP_HASH" == "$LOC_HASH" ]; then
    echo "result=NO_CHANGES"
    exit 0
fi

git checkout "$MIR_BR" || git checkout -b "$MIR_BR"
git reset --hard "$UP_HASH"
git push origin "$MIR_BR" --force

CAN_MERGE=false
FILE=".github/auto-update-default.txt"
if [ -f "$FILE" ]; then
    VAL=$(grep -v '^#' "$FILE" | grep -v '^[[:space:]]*$' | head -n 1 | xargs | tr '[:upper:]' '[:lower:]')
    [[ "$VAL" =~ ^(true|1|on)$ ]] && CAN_MERGE=true
fi

if [ "$CAN_MERGE" = true ]; then
    git checkout "$TGT_BR"
    git merge "origin/$MIR_BR" --no-edit && git push origin "$TGT_BR"
    echo "result=UPDATED"
else
    echo "result=MIRROR_ONLY"
fi
