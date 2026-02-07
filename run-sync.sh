#!/bin/bash
# 1. Загружаем секреты
set -a
[ -f "./.env" ] && . "./.env"
[ -f "../.env" ] && . "../.env"
set +a

REPO_NAME=$(basename "$PWD")
echo "--- 🛠 Local Sync Starting: $REPO_NAME ---"

# 2. Запускаем синхронизацию зеркала
SYNC_OUT=$(bash ../ci-lib/scripts/sync-mirror.sh)

# Парсим результаты из вывода
CHANGED=$(echo "$SYNC_OUT" | grep "changed=" | cut -d'=' -f2)
CRITICAL=$(echo "$SYNC_OUT" | grep "critical=" | cut -d'=' -f2)
CRIT_LIST=$(echo "$SYNC_OUT" | grep "critical_list=" | cut -d'=' -f2)
HASH=$(echo "$SYNC_OUT" | grep "hash=" | cut -d'=' -f2)

if [[ "$CHANGED" == "true" ]]; then

    # 3. Обработка критических изменений
    DO_MERGE=true
    if [[ "$CRITICAL" == "true" ]]; then
        echo -e "\n⚠️  [ВНИМАНИЕ] Обнаружены изменения в критических файлах:"
        echo -e "   $CRIT_LIST\n"

        # Интерактивный запрос пользователю
        read -p "Критическое обновление. Продолжить автоматический мердж? (y/n): " confirm
        if [[ $confirm != [yY] ]]; then
            echo "🛑 Мердж отменен пользователем."
            DO_MERGE=false
            STATUS="BLOCKED_CRITICAL"
        fi
    fi

    # 4. Выполнение мерджа (если не заблокировано)
    if [[ "$DO_MERGE" == "true" ]]; then
        # Передаем "false" в merge-target.sh, так как пользователь разрешил мердж
        MERGE_OUT=$(bash ../ci-lib/scripts/merge-target.sh "" "" "false")

        # Парсим результат мерджа
        if [[ "$MERGE_OUT" == *"merge_result=UPDATED"* ]]; then
            STATUS="LOCAL_UPDATED"
        else
            STATUS="LOCAL_SKIPPED"
        fi
    fi

    # 5. Генерация сообщения и отправка
    MSG=$(bash ../ci-lib/scripts/gen-message.sh "$REPO_NAME" "" "$STATUS" "$HASH" "0" "$CRIT_LIST")

    # Отправляем уведомление (force=true для локального запуска)
    bash ../ci-lib/scripts/tg-notify.sh "$MSG" "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "$TELEGRAM_TOPIC_ID" "true"

    echo -e "\n✅ Работа завершена. Статус: $STATUS"
else
    echo "      Upstream changes not found."
fi
