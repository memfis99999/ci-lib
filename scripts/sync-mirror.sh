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
    echo "critical=false"
else
    # --- ЛОГИКА СТОП-КРАНА ---
    CRITICAL=false
    CRIT_LIST=""
    RULES_FILE="$CONF_DIR/critical-rules.txt"

    if [ -f "$RULES_FILE" ]; then
        # Получаем список измененных файлов
        CHANGED_FILES=$(git diff --name-only "$MIR_HASH" "$UP_HASH")

        # Проверяем каждый измененный файл на соответствие правилам из файла
        # grep -Ff читает строки из файла как фиксированные строки-паттерны
        MATCHES=$(echo "$CHANGED_FILES" | grep -Ff "$RULES_FILE")

        if [ -n "$MATCHES" ]; then
            CRITICAL=true
            # Берем первые 3 файла для уведомления
            CRIT_LIST=$(echo "$MATCHES" | head -n 3 | xargs)
        fi
    fi

    echo "critical=$CRITICAL"
    echo "critical_list=$CRIT_LIST"
    # --- КОНЕЦ ЛОГИКИ ---

    git checkout "$MIR_BR" || git checkout -b "$MIR_BR"
    git reset --hard "$UP_HASH"
    git push origin "$MIR_BR" --force
    echo "changed=true"
    echo "hash=$(git rev-parse --short "$UP_HASH")"
fi
