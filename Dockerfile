FROM python:3.11-slim

# Установка необходимых системных пакетов
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    xvfb \
    firefox-esr \
    && rm -rf /var/lib/apt/lists/*

# Определяем архитектуру и устанавливаем geckodriver
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        GECKO_ARCH="linux-aarch64"; \
    elif [ "$ARCH" = "x86_64" ]; then \
        GECKO_ARCH="linux64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    GECKODRIVER_VERSION=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') && \
    echo "Downloading geckodriver ${GECKODRIVER_VERSION} for ${GECKO_ARCH}" && \
    wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-${GECKO_ARCH}.tar.gz" && \
    tar -xzf "geckodriver-${GECKODRIVER_VERSION}-${GECKO_ARCH}.tar.gz" -C /usr/local/bin && \
    rm "geckodriver-${GECKODRIVER_VERSION}-${GECKO_ARCH}.tar.gz" && \
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

# Запуск Xvfb в фоне и затем бота
CMD ["sh", "-c", "Xvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 & python main.py"]