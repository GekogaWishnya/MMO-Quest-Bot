#!/bin/bash
# Скрипт для добавления нового бота

set -e

# Проверка аргументов
if [ "$#" -lt 3 ]; then
    echo ""
    echo "Use: ./add-bot.sh <LOGIN> <PASSWORD> <MOB> [TIMEOUT]"
    echo ""
    echo "Example:"
    echo "  ./add-bot.sh Player_123 mypass123 \"Чумовой гриб\""
    echo "  ./add-bot.sh Player_456 mypass456 \"Скелет воин\" 60"
    echo ""
    exit 1
fi

LOGIN=$1
PASSWORD=$2
MOB=$3
TIMEOUT=${4:-30}

# Создаём папку для бота
BOT_DIR="bots/bot-${LOGIN}"

if [ -d "$BOT_DIR" ]; then
    echo ""
    echo "Bot with login ${LOGIN} already exists!"
    echo "Path: ${BOT_DIR}"
    echo ""
    exit 1
fi

mkdir -p "$BOT_DIR"

echo ""
echo "Creating directory: ${BOT_DIR}"

# Создаём docker-compose.yml
cat > "${BOT_DIR}/docker-compose.yml" << 'EOF'
services:
  mmo-bot:
    image: pulsarbf/mmo-bot:latest
    container_name: mmo-bot-${LOGIN}
    restart: on-failure:5
    env_file:
      - .env
    environment:
      - TZ=Europe/Moscow
EOF

# Создаём .env
cat > "${BOT_DIR}/.env" << EOF
LOGIN=${LOGIN}
PASSWORD=${PASSWORD}
MOB=${MOB}
TIMEOUT=${TIMEOUT}
EOF

echo "Bot ${LOGIN} created successfully!"
echo ""
echo "Settings:"
echo "   Login: ${LOGIN}"
echo "   Password: ${PASSWORD}"
echo "   Mob: ${MOB}"
echo "   Timeout: ${TIMEOUT}s"
echo ""
echo "Start the bot:"
echo "   cd ${BOT_DIR} && docker-compose up -d"
echo ""
echo "Or start all bots at once:"
echo "   ./start-all.sh"
echo ""