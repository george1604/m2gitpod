#!/bin/bash

if [ -f $GITPOD_REPO_ROOT/db-installed.flag ]; then
    echo "Magento is already installed!"
    exit 0
fi

# Create database
sudo mysql -uroot -e 'SET GLOBAL innodb_file_per_table=ON;'
sudo mysql -uroot -e 'CREATE DATABASE IF NOT EXISTS magento2;'
sudo mysql -uroot -e 'ALTER USER "root"@"localhost" IDENTIFIED WITH caching_sha2_password BY "zitec123";'

# Import dump
tar -xvzf database.tar.gz
mysql -uroot -pzitec123 magento2 < database.sql

# Get URL
if ! command -v gp &> /dev/null
then
    url=$(cat .docker/.env | grep '^HOST=' | grep -oe '[^=]*$')
    url="https://"$url
else
    url=$(gp url | awk -F"//" {'print $2'}) && url+="/"
    url="https://8002-"$url
fi
echo "Magento url: $url"

# Install Magento
echo "Install Magento"
php bin/magento setup:install --db-name='magento2' --db-user='root' --db-password='zitec123' --base-url=$url --backend-frontname='admin' --admin-user='admin' --admin-password='admin123' --admin-email='test@zitec.com' --admin-firstname='Admin' --admin-lastname='User' --use-rewrites='1' --use-secure='1' --base-url-secure=$url --use-secure-admin='1' --language='en_US' --db-host='127.0.0.1' --timezone='Europe/Bucharest' --currency='RON' --session-save='redis'

git checkout -- .gitignore


# Disable CSP & 2FA modules
echo "Disable modules & setup config"
php bin/magento module:disable Magento_Csp Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth

# Magento config
php bin/magento setup:config:set --session-save=redis --session-save-redis-host=127.0.0.1 --session-save-redis-log-level=3 --session-save-redis-db=0 --session-save-redis-port=6379 -n;
php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=127.0.0.1 --cache-backend-redis-db=1 -n;
php bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=127.0.0.1 --page-cache-redis-db=2 -n;
php bin/magento config:set catalog/search/engine 'elasticsearch8' -n;

# Setup upgrade
echo "Setup upgrade"
php bin/magento setup:upgrade

# Reindex & compile
echo "Reindex & compile"
php bin/magento indexer:reindex
php bin/magento setup:di:compile

touch $GITPOD_REPO_ROOT/db-installed.flag
