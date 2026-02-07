# Используем официальный образ Python
FROM python:3.11-slim

# Устанавливаем системные зависимости для Firefox и Selenium
RUN apt-get update && apt-get install -y \
    firefox-esr \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и устанавливаем geckodriver
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz \
    && tar -xzf geckodriver-v0.36.0-linux64.tar.gz \
    && mv geckodriver /usr/local/bin/ \
    && chmod +x /usr/local/bin/geckodriver \
    && rm geckodriver-v0.36.0-linux64.tar.gz

# Создаем рабочую директорию
WORKDIR /app

# Копируем файл зависимостей
COPY requirements.txt .

# Устанавливаем Python-зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код бота и entrypoint скрипт
COPY mmo_bot.py .
COPY entrypoint.sh .

# Делаем entrypoint исполняемым
RUN chmod +x entrypoint.sh

# Используем entrypoint для умной обработки ошибок
ENTRYPOINT ["./entrypoint.sh"]