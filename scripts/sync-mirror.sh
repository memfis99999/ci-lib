#!/bin/bash
CONF_DIR=".github/sync"
URL=${1:-$(cat $CONF_DIR/upstream-url.txt 2>/dev/null)}
UP_BR=${2:-$(cat $CONF_DIR/upstream-branch.txt 2>/dev/null || echo "master")}
MIR_BR=${3:-$(cat $CONF_DIR/mirror-branch.txt 2>/dev/null || echo "upstream-mirror")}

git remote add upstream "$URL" 2>/dev/null || git remote set-url upstream "$URL"
git fetch upstream "$UP_BR" --tags --prune

UP_HASH=$(git rev-parse upstream/"$UP_BR")
MIR_HASH=$(git rev-parse origin/"$MIR_BR" 2>/dev/null || echo "none")

if [ "$UP_HASH" == "$MIR_HASH" ]; then
    echo "changed=false"
else
    git checkout "$MIR_BR" || git checkout -b "$MIR_BR"
    git reset --hard "$UP_HASH"
    git push origin "$MIR_BR" --force
    echo "changed=true"
    echo "hash=$(git rev-parse --short "$UP_HASH")"
fi
