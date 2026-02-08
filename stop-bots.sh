#!/bin/bash
# Скрипт для остановки конкретных ботов

set -e

if [ "$#" -eq 0 ]; then
    echo ""
    echo "Usage: ./stop-bots.sh <LOGIN1> <LOGIN2> <LOGIN3> ..."
    echo ""
    echo "Examples:"
    echo "  ./stop-bots.sh Player_123"
    echo "  ./stop-bots.sh Player_123 Player_456"
    echo "  ./stop-bots.sh Player_123 Player_456 Player_789"
    echo ""
    if [ -d "bots" ]; then
        echo "Available bots:"
        ls -1 bots/ | grep "^bot-" | sed 's/bot-/  - /'
        echo ""
    fi
    exit 1
fi

if [ ! -d "bots" ]; then
    echo "Folder bots/ not found!"
    echo ""
    exit 1
fi

echo ""
echo "Stopping specified bots..."
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_BOTS=""

for login in "$@"; do
    BOT_DIR="bots/bot-${login}"
    
    if [ ! -d "$BOT_DIR" ]; then
        echo "Bot ${login} not found!"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_BOTS="${FAILED_BOTS}  - ${login}\n"
        continue
    fi
    
    echo ""
    echo "Stopping bot-${login}..."
    (cd "$BOT_DIR" && docker-compose down)
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    echo ""
done

echo ""
echo "════════════════════════════════════════════════════════════════"

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "Stopped: ${SUCCESS_COUNT} bot(s)"
    echo ""
fi

if [ $FAILED_COUNT -gt 0 ]; then
    echo "Not found: ${FAILED_COUNT} bot(s)"
    echo ""
    echo "Bots not found:"
    echo -e "$FAILED_BOTS"
    echo "Available bots:"
    ls -1 bots/ | grep "^bot-" | sed 's/bot-/  - /'
    echo ""
fi
