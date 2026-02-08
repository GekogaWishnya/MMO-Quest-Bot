#!/bin/bash
# Скрипт для удаления бота

set -e

if [ "$#" -ne 1 ]; then
    echo ""
    echo "Usage: ./remove-bot.sh <LOGIN>"
    echo ""
    echo "Example:"
    echo "  ./remove-bot.sh Player_123"
    echo ""
    echo "Existing bots:"
    if [ -d "bots" ]; then
        ls -1 bots/ | grep "^bot-" | sed 's/bot-/  - /'
        echo ""
    else
        echo "  (no bots)"
        echo ""
    fi
    exit 1
fi

LOGIN=$1
BOT_DIR="bots/bot-${LOGIN}"

if [ ! -d "$BOT_DIR" ]; then
    echo "Bot ${LOGIN} not found!"
    echo ""
    echo "Existing bots:"
    if [ -d "bots" ]; then
        ls -1 bots/ | grep "^bot-" | sed 's/bot-/  - /'
        echo ""
    else
        echo "  (no bots)"
        echo ""
    fi
    exit 1
fi

echo ""
echo "Are you sure you want to remove bot ${LOGIN}?"
echo "Path: ${BOT_DIR}"
read -p "Type 'yes' to confirm: " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Cancelled."
    echo ""
    exit 0
fi

echo ""
echo "Stopping container..."
(cd "$BOT_DIR" && docker-compose down 2>/dev/null || true)

echo "Deleting folder..."
rm -rf "$BOT_DIR"

echo "Bot ${LOGIN} removed!"
echo ""
