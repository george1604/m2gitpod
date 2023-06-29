#!/bin/bash


# Create database
mysql -u gitpod -p -e 'CREATE DATABASE IF NOT EXISTS magento2;'
mysql -u gitpod -e 'ALTER USER 'gitpod'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'zitec123';'


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
php bin/magento setup:config:set --session-save=redis --session-save-redis-host=127.0.0.1 --session-save-redis-log-level=3 --session-save-redis-db=0 --session-save-redis-port=6379;
php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=127.0.0.1 --cache-backend-redis-db=1;
php bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=127.0.0.1 --page-cache-redis-db=2;

# Setup upgrade
echo "Setup upgrade"
php bin/magento setup:upgrade


# php bin/magento config:set web/cookie/cookie_path "/" --lock-config
# php bin/magento config:set web/cookie/cookie_domain ".gitpod.io" --lock-config
