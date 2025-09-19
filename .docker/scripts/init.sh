#!/bin/bash

# Move mysql data folder to workspace
sudo mv /var/lib/mysql $GITPOD_REPO_ROOT/;

# Move vendor to workspace
mv /home/gitpod/magento/vendor $GITPOD_REPO_ROOT/;

# Copy sample data media files to workspace
cp -r /home/gitpod/magento/pub/media/* $GITPOD_REPO_ROOT/pub/media/
