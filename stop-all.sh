#!/bin/bash
# Скрипт для остановки всех ботов

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

echo "Stopping ${BOT_COUNT} bot(s)..."
echo ""

for bot_dir in bots/bot-*; do
    if [ -d "$bot_dir" ]; then
        bot_name=$(basename "$bot_dir")
        echo "Stopping ${bot_name}..."
        (cd "$bot_dir" && docker-compose down)
        echo ""
    fi
done

echo ""
echo "All bots stopped!"
echo ""