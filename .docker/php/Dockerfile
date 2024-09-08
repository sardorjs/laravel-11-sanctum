FROM php:8.3.9-fpm

# Установка необходимые пакеты и расширения
RUN \
    # обновляет список доступных пакетов из репозиториев, чтобы убедиться что вы устанавливаете последние версии
    apt-get update && \
    # Параметр -y автоматически отвечает "да" на все запросы на установку пакетов.
    apt-get install -y \
        # bash: Альтернативный командный интерпретатор
        bash \
        # nano: Альтернативный командный интерпретатор
        nano \
        # git: Система управления версиями.
        git \
        # unzip:
        unzip \
        # locales:
        locales \
        # curl: Утилита для передачи данных с URL.
        curl \
        # libpng-dev: Библиотека для работы с PNG изображениями.
        libpng-dev \
        # libjpeg-dev: Библиотека для работы с JPEG изображениями.
        libjpeg-dev \
        # libwebp-dev: Библиотека для работы с WebP изображениями.
        libwebp-dev \
        # libfreetype6-dev: Библиотека для работы с шрифтами FreeType.
        libfreetype6-dev \
        # libonig-dev: Библиотека для работы с регулярными выражениями (необходима для mbstring).
        libonig-dev \
        # libzip-dev: Библиотека для работы с ZIP-архивами.
        libzip-dev \
        # libicu-dev: Библиотека для поддержки Unicode и международных стандартов.
        libicu-dev \
        # g++: Компилятор C++. - понадобиться для установки нативных расширений таких как xdebug, npm, nodejs
        g++ \
        # make: Утилита для автоматизации сборки.
        make \
        # autoconf: Инструмент для генерации скриптов конфигурации. - понадобиться для Makefile
        autoconf && \
        # docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp: Настройка расширения GD с поддержкой FreeType, JPEG и WebP.
        docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
        # docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql zip intl: Установка расширений GD, mbstring, pdo (Расширение для работы с базами данных через объектно-ориентированный интерфейс PDO (PHP Data Objects). Это обеспечивает универсальный способ работы с разными СУБД.), pdo_mysql (Расширение для PDO, которое предоставляет поддержку работы с базами данных MySQL.), zip(Расширение для работы с архивами ZIP. Позволяет создавать и извлекать ZIP-архивы из PHP-скриптов.) и intl (Расширение для интернационализации и локализации. Предоставляет функции для работы с различными языками, форматами чисел, дат и времени.) с использованием всех доступных процессоров - "-j$(nproc)".
        docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql zip intl mysqli opcache exif


# Установка Composer - это менеджер зависимостей для PHP.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Переменная для пути где будут храниться наш проект - внутри сборки, после сборки удаляется
ARG DOCKER_BASE_PATH=/var/www

# Переменная для пути где будут храниться наш проект - после сборки доступен, и даже в запускаемых файлах .php
ENV DOCKER_BASE_PATH=${DOCKER_BASE_PATH}

# Создание рабочей директории - Эта команда устанавливает /var/www/html в качестве рабочей директории для всех последующих команд. Это значит, что все команды, такие как COPY и RUN, будут выполняться в этой директории.
WORKDIR ${DOCKER_BASE_PATH}

# Скопируем проект в рабочую директорию
COPY . ${DOCKER_BASE_PATH}

# Установка Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Установка зависимостей проекта: Эта команда выполняет установку зависимостей, указанных в composer.json, используя Composer.
# Параметры: --no-dev: Не устанавливать зависимости, указанные в разделе require-dev вашего composer.json. --optimize-autoloader: Оптимизировать автозагрузчик для более быстрого выполнения.
RUN composer install --no-dev --optimize-autoloader

# Копируем .env.example в .env, если .env отсутствует
# Обновляем команду для проверки наличия .env файла и копирования .env.example
RUN if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi

# Настройка прав доступа
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Генерируем ключ приложения и настраиваем кэш
RUN php artisan key:generate && \
    php artisan config:clear && \
    php artisan route:cache

# Эта команда копирует файл laravel.ini в директорию конфигурации PHP, где он будет автоматически загружен и применен PHP-FPM.
COPY .docker/php/laravel.ini /usr/local/etc/php/conf.d/

# команда для запуска PHP-FPM
ENTRYPOINT ["php-fpm"]
