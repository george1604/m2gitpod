FROM gitpod/workspace-base:2023-05-09-03-02-39

USER root
ENV TRIGGER_REBUILD=3

# Install supervisor, envsubst
RUN apt-get update && apt-get install -y supervisor gettext-base && mkdir -p /var/log/supervisor

# Install php-fpm8.2 & nginx
RUN for _ppa in 'ppa:ondrej/php' 'ppa:ondrej/nginx-mainline'; do add-apt-repository -y "$_ppa"; done \
    && install-packages \
        composer \
        nginx \
        nginx-extras \
        nginx-doc \
        php8.2 \
        php8.2-bcmath \
        php8.2-ctype \
        php8.2-curl \
        php8.2-fpm \
        php8.2-gd \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-soap \
        php8.2-tokenizer \
        php8.2-xml \
        php8.2-zip \
        unzip \
        wget \
        git \
    && mkdir -p /var/run/nginx \
    && chown -R gitpod:gitpod /etc/nginx /var/run/nginx /var/lib/nginx/ /var/log/nginx/

# Disable Opcache
RUN mv /etc/php/8.2/mods-available/opcache.ini /etc/php/8.2/mods-available/opcache.ini.bkp

# Copy config files for php-fpm & nginx
COPY .docker/config/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf
COPY .docker/config/sp-php-fpm.conf /etc/supervisor/conf.d/sp-php-fpm.conf
COPY .docker/config/nginx.conf /etc/nginx


# Install MySQL
RUN install-packages mysql-server \
 && mkdir -p /var/run/mysqld /var/log/mysql \
 && chown -R gitpod:gitpod /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade

# Copy our own MySQL config
COPY .docker/config/mysql.cnf /etc/mysql/conf.d/mysqld.cnf
COPY .docker/config/.my.cnf /home/gitpod
COPY .docker/config/sp-mysql.conf /etc/supervisor/conf.d/mysql.conf
RUN sudo chown gitpod:gitpod /home/gitpod/.my.cnf

# Install default-login for MySQL clients
COPY .docker/config/client.cnf /etc/mysql/conf.d/client.cnf

# Install Elasticsearch
RUN curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.4.0-linux-x86_64.tar.gz --output elasticsearch-8.4.0-linux-x86_64.tar.gz \
    && tar -xzf elasticsearch-8.4.0-linux-x86_64.tar.gz \
    && sed -i -e '$a-Xms512m' elasticsearch-8.4.0/config/jvm.options \
    && sed -i -e '$a-Xmx512m' elasticsearch-8.4.0/config/jvm.options

# Copy Elasticsearch config
COPY .docker/config/sp-elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# Install Redis.
RUN sudo apt-get update \
 && sudo apt-get install -y \
  redis-server \
 && sudo rm -rf /var/lib/apt/lists/*

COPY .docker/config/sp-redis.conf /etc/supervisor/conf.d/redis.conf

# Change ownership of directories
RUN sudo chown -R gitpod:gitpod /etc/php \
    && sudo chown -R gitpod:gitpod /etc/nginx \
    && sudo chown -R gitpod:gitpod /etc/init.d/ \
    && sudo chown -R gitpod:gitpod /home/gitpod/elasticsearch-8.4.0/ \
    && sudo echo "net.core.somaxconn=65536" | sudo tee /etc/sysctl.conf

# Replace shell with bash so we can source files
RUN sudo rm /bin/sh && sudo ln -s /bin/bash /bin/sh

USER gitpod
