#!/bin/bash

if [ "$1" == "on" ]; then
    # Enable xdebug
    sudo mv /etc/php/8.2/mods-available/xdebug.ini.bkp /etc/php/8.2/mods-available/xdebug.ini
    sudo supervisorctl restart php-fpm
    echo "Xdebug enabled"
else
    # Disable xdebug
    sudo mv /etc/php/8.2/mods-available/xdebug.ini /etc/php/8.2/mods-available/xdebug.ini.bkp
    sudo supervisorctl restart php-fpm
    echo "Xdebug disabled"
fi
