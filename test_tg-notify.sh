#!/bin/bash
# 1. Загружаем секреты
set -a
[ -f "./.env" ] && . "./.env"
[ -f "../.env" ] && . "../.env"
set +a

REPO_NAME=$(basename "$PWD")
echo "--- 🛠 Local Sync Starting: $REPO_NAME ---"

    # 5. Генерация сообщения и отправка
    MSG=$(bash ../ci-lib/scripts/gen-message.sh "$REPO_NAME" "" "$STATUS" "$HASH" "0" "$CRIT_LIST")

    # Отправляем уведомление (force=true для локального запуска)
    bash ../ci-lib/scripts/tg-notify.sh "$MSG" "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "$TELEGRAM_TOPIC_ID" "true"
