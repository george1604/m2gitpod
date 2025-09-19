#!/bin/bash

# Move mysql data folder to workspace
sudo mv /var/lib/mysql /workspaces/m2gitpod/;

# Move vendor to workspace
mv /home/gitpod/magento/vendor /workspaces/m2gitpod/vendor;

# Copy sample data media files to workspace
cp -r /home/gitpod/magento/pub/media/* /workspaces/m2gitpod/pub/media/
