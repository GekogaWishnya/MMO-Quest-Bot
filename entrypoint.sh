#!/bin/bash
# скрипт для умной обработки ошибок

# запускаем бота
python -u mmo_bot.py
exit_code=$?

# обрабатываем код выхода
case $exit_code in
  0)
    echo "Bot ended successfully."
    exit 0
    ;;
  78)
    echo ""
    echo "Configuration error - the container will not be restarted"
    echo "Fix the .env file and restart: docker-compose up -d"
    exit 0  # выходим с кодом 0 - Docker НЕ перезапустит
    ;;
  *)
    echo ""
    echo "Bot crashed with error (code $exit_code)"
    echo "Docker will try to restart the bot..."
    exit $exit_code  # выходим с исходным кодом - Docker перезапустит
    ;;
esac