#!/bin/bash
# Set up DVWA
cd /var/www/html/config

# Check if config.inc.php exists, and if not, copy the default config file
if [ ! -f config.inc.php ]; then
    cp config.inc.php.dist config.inc.php
    echo "config.inc.php was missing, copied config.inc.php.dist to config.inc.php"
else
    echo "config.inc.php already exists, skipping copy."
fi

# Set up database (create dvwa database, etc.)
sudo mysql -u root -e "
CREATE DATABASE IF NOT EXISTS dvwa;
CREATE USER 'dvwausr'@'127.0.0.1' IDENTIFIED BY 'dvwar@123';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwausr'@'127.0.0.1';
FLUSH PRIVILEGES;
"
cd /var/www/dvwa
sudo chmod -R 777 /var/www/html/hackable/uploads/
