#!/bin/bash
# Скрипт для запуска всех ботов

set -e

if [ ! -d "bots" ]; then
    echo ""
    echo "Folder bots/ not found!"
    echo "First, create bots using: ./add-bot.sh"
    echo ""
    exit 1
fi

BOT_COUNT=$(find bots -maxdepth 1 -type d -name "bot-*" | wc -l)

if [ "$BOT_COUNT" -eq 0 ]; then
    echo ""
    echo "Bots not found!"
    echo "Create bots using: ./add-bot.sh <LOGIN> <PASSWORD> <MOB>"
    echo ""
    exit 1
fi

echo ""
echo "Starting ${BOT_COUNT} bot(s)..."
echo ""

for bot_dir in bots/bot-*; do
    if [ -d "$bot_dir" ]; then
        bot_name=$(basename "$bot_dir")
        echo "Starting ${bot_name}..."
        (cd "$bot_dir" && docker-compose up -d)
        echo ""
    fi
done

echo ""
echo "All bots started!"
echo ""
echo "Check status:"
echo "   docker ps"
echo ""
echo "View logs:"
echo "   ./logs.sh"
echo ""
