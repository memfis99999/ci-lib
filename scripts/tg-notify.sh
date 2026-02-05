#!/bin/bash
MSG=$1; TOKEN=$2; CHAT=$3; TOPIC=$4; FORCE=$5
CONF_DIR=".github/sync"
CONF_BR=${6:-$(cat $CONF_DIR/target-branch.txt 2>/dev/null || echo "master")}

ENABLED=false
if [ "$FORCE" = "true" ]; then
    ENABLED=true
else
    # Читаем флаг из папки sync/ нужной ветки
    CONTENT=$(git show "origin/$CONF_BR:$CONF_DIR/telegram-enabled.txt" 2>/dev/null || echo "")
    VAL=$(echo "$CONTENT" | grep -v '^#' | xargs | tr '[:upper:]' '[:lower:]')
    [[ "$VAL" =~ ^(true|1|on)$ ]] && ENABLED=true
fi

if [ "$ENABLED" = true ]; then
    JSON_MSG=$(echo "$MSG" | jq -aRs .)
    PAYLOAD="{\"chat_id\": \"$CHAT\", \"text\": $JSON_MSG, \"parse_mode\": \"HTML\"}"
    [[ -n "$TOPIC" ]] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg tid "$TOPIC" '. + {message_thread_id: $tid}')
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -H "Content-Type: application/json" -d "$PAYLOAD" > /dev/null
fi
