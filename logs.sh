#!/bin/bash
# Скрипт для просмотра логов всех ботов

set -e

if [ ! -d "bots" ]; then
    echo "Folder bots/ not found!"
    exit 1
fi

BOT_COUNT=$(find bots -maxdepth 1 -type d -name "bot-*" | wc -l)

if [ "$BOT_COUNT" -eq 0 ]; then
    echo "Bots not found!"
    exit 1
fi

echo "Logs of all bots (last 20 lines):"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

for bot_dir in bots/bot-*; do
    if [ -d "$bot_dir" ]; then
        bot_name=$(basename "$bot_dir")
        echo "${bot_name}:"
        echo "────────────────────────────────────────────────────────────────"
        (cd "$bot_dir" && docker-compose logs --tail=20)
        echo ""
    fi
done

echo "════════════════════════════════════════════════════════════════"
echo ""
echo "To view logs in real-time:"
echo "   cd bots/bot-<LOGIN> && docker-compose logs -f"
echo ""
