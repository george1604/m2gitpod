FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV TRIGGER_REBUILD=1

RUN apt-get update \
    && apt-get install -y  \
      apt-transport-https \
      unzip \
      wget \
      git \
      sqlite3 \
      php8.3 \
      php8.3-cli \
      php8.3-dev \
      php8.3-bcmath \
      php8.3-ctype \
      php8.3-curl \
      php8.3-gd \
      php8.3-intl \
      php8.3-mbstring \
      php8.3-mysql \
      php8.3-sqlite3 \
      php8.3-tokenizer \
      php8.3-xml \
      php8.3-zip \
      php8.3-dom \
      php8.3-xdebug \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

# Install apcu
RUN yes 'no' | pecl install -o -f apcu-5.1.23 \
    && echo 'extension=apcu.so' > /etc/php/8.3/cli/conf.d/21-apcu.ini

    USER vscode

# Expose HTTP port