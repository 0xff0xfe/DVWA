#!/bin/bash
# Set up DVWA
cd /var/www/html/config
cp config.inc.php.dist config.inc.php
# Set up database (create dvwa database, etc.)
mysql -u root -e "CREATE DATABASE dvwa;"
CREATE USER 'dvwausr'@'127.0.0.1' IDENTIFIED BY "dvwar@123";
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwausr'@'localhost' IDENTIFIED BY 'dvwa@123';
cd /var/www/dvwa
sudo chmod -R 777 /var/www/html/dvwa/hackable/uploads
