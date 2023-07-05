#!/bin/bash

# Composer install
composer config -g -a http-basic.repo.magento.com 64229a8ef905329a184da4f174597d25 a0df0bec06011c7f1e8ea8833ca7661e
composer install --no-interaction --optimize-autoloader --ignore-platform-reqs
composer dumpautoload

# Move mysql data folder
sudo mv /var/lib/mysql $GITPOD_REPO_ROOT/;
