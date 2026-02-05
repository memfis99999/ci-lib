#!/bin/bash
# Параметры: URL_UPSTREAM, BRANCH_UPSTREAM, MIRROR_NAME
URL=$1; UP_BR=$2; MIR_BR=$3

git remote add upstream "$URL" 2>/dev/null || git remote set-url upstream "$URL"
git fetch upstream "$UP_BR" --tags --prune

UP_HASH=$(git rev-parse upstream/"$UP_BR")
MIR_HASH=$(git rev-parse origin/"$MIR_BR" 2>/dev/null || echo "none")

if [ "$UP_HASH" == "$MIR_HASH" ]; then
    echo "changed=false"
    exit 0
fi

git checkout "$MIR_BR" || git checkout -b "$MIR_BR"
git reset --hard "$UP_HASH"
git push origin "$MIR_BR" --force
echo "changed=true"
echo "hash=$(git rev-parse --short "$UP_HASH")"
