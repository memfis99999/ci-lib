#!/bin/bash
# Загружаем секреты
set -a; [ -f ../.env ] && . ../.env; set +a

REPO_NAME=$(basename "$PWD")

# 1. Запускаем синхронизацию зеркала
# Перенаправляем вывод в переменные через 'eval' или парсим строки
SYNC_OUT=$(bash ../ci-lib/scripts/sync-mirror.sh "https://github.com/Klipper3d/klipper.git" "master" "upstream-mirror")

if [[ "$SYNC_OUT" == *"changed=true"* ]]; then
    # 2. Делаем мердж
    MERGE_OUT=$(bash ../ci-lib/scripts/merge-target.sh "upstream-mirror" "master")
    
    # 3. Генерируем сообщение
    MSG=$(bash ../ci-lib/scripts/gen-message.sh "$REPO_NAME" "master" "LOCAL_UPDATED" "hash_here" "0" "local")
    
    # 4. Отправляем (через notify.sh из предыдущего совета)
    bash ../ci-lib/scripts/notify.sh "$MSG" "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "$TELEGRAM_TOPIC_ID" "true" "master"
fi
