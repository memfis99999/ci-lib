#!/bin/bash
# 1. Загружаем секреты из родительской папки
# (Используем полную проверку пути, чтобы скрипт был надежнее)
set -a
[ -f "./.env" ] && . "./.env"
[ -f "../.env" ] && . "../.env"
set +a

# Проверяем, что мы в папке репозитория
if [ ! -d ".git" ]; then
    echo "❌ Ошибка: Запусти этот скрипт внутри папки с репозиторием (например, klipper/)"
    exit 1
fi

REPO_NAME=$(basename "$PWD")

echo "--- 🛠 Local Sync Starting: $REPO_NAME ---"

# 2. Запускаем синхронизацию зеркала (без аргументов!)
# Скрипт сам возьмет всё из .github/sync/
SYNC_OUT=$(bash ../ci-lib/scripts/sync-mirror.sh)

if [[ "$SYNC_OUT" == *"changed=true"* ]]; then
    # Достаем хеш из вывода (строка вида hash=abc1234)
    HASH=$(echo "$SYNC_OUT" | grep "hash=" | cut -d'=' -f2)
    
    # 3. Делаем мердж (без аргументов!)
    MERGE_OUT=$(bash ../ci-lib/scripts/merge-target.sh)
    
    # Определяем статус мерджа для сообщения
    if [[ "$MERGE_OUT" == *"merge_result=UPDATED"* ]]; then
        STATUS="LOCAL_UPDATED"
    else
        STATUS="LOCAL_MIRROR_ONLY"
    fi
    
    # 4. Генерируем сообщение
    # Передаем: REPO, BRANCH(пусто), STATUS, HASH, RUN_ID(0)
    MSG=$(bash ../ci-lib/scripts/gen-message.sh "$REPO_NAME" "" "$STATUS" "$HASH" "0")
    
    # 5. Отправляем уведомление
    # Скрипт сам найдет ветку конфига для проверки telegram-enabled.txt
    bash ../ci-lib/scripts/tg-notify.sh "$MSG" "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "$TELEGRAM_TOPIC_ID" "true"
    
    echo "✅ Done! Result: $STATUS"
else
    echo "      No changes in upstream."
fi
