#!/bin/bash

# Prepare the nginx configuration
envsubst '${GITPOD_REPO_ROOT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf;

# Change data dir for MySQL
sed -i 's#/var/lib/mysql#'$GITPOD_REPO_ROOT'/mysql#g' /etc/mysql/conf.d/mysqld.cnf;
sudo sed -i 's#/var/lib/mysql#'$GITPOD_REPO_ROOT'/mysql#g' /etc/supervisor/conf.d/mysql.conf;

# Start services
sudo /etc/init.d/supervisor start &

# Wait for MySQL to be ready
if ! command -v gp &> /dev/null
then
    sleep 20;
else
    gp ports await 3306;
fi
