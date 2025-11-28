FROM python:3.11-slim

# Установка необходимых системных пакетов
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Установка Firefox ESR
RUN apt-get update && apt-get install -y \
    firefox-esr \
    && rm -rf /var/lib/apt/lists/*

# Установка geckodriver
RUN GECKODRIVER_VERSION=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') && \
    wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" -C /usr/local/bin && \
    rm "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    chmod +x /usr/local/bin/geckodriver

# Создание рабочей директории
WORKDIR /app

# Копирование файла зависимостей
COPY requirements.txt .

# Установка Python зависимостей
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копирование кода бота
COPY main.py .

# Создание пользователя для безопасности
RUN useradd -m -u 1000 botuser && \
    chown -R botuser:botuser /app

USER botuser

# Настройка переменных окружения для Firefox в headless режиме
ENV MOZ_HEADLESS=1
ENV DISPLAY=:99

# Запуск бота
CMD ["python", "main.py"]
 