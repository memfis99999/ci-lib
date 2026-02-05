#!/bin/bash
# params: MSG, TOKEN, CHAT_ID, TOPIC_ID, FORCE, CONFIG_BRANCH
MSG=$1; TOKEN=$2; CHAT=$3; TOPIC=$4; FORCE=$5; CONF_BR=$6

ENABLED=false
if [ "$FORCE" = "true" ]; then
    ENABLED=true
else
    CONTENT=$(git show "origin/$CONF_BR:.github/telegram-enabled.txt" 2>/dev/null || echo "")
    VAL=$(echo "$CONTENT" | grep -v '^#' | grep -v '^[[:space:]]*$' | head -n 1 | xargs | tr '[:upper:]' '[:lower:]')
    [[ "$VAL" =~ ^(true|1|on)$ ]] && ENABLED=true
fi

if [ "$ENABLED" = true ]; then
    JSON_MSG=$(echo "$MSG" | jq -aRs .)
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    PAYLOAD="{\"chat_id\": \"$CHAT\", \"text\": $JSON_MSG, \"parse_mode\": \"HTML\"}"
    [[ -n "$TOPIC" ]] && PAYLOAD=$(echo "$PAYLOAD" | jq --arg tid "$TOPIC" '. + {message_thread_id: $tid}')
    
    curl -s -X POST "$URL" -H "Content-Type: application/json" -d "$PAYLOAD" > /dev/null
    echo "Notification sent."
fi
