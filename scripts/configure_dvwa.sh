#!/bin/bash
# Set up DVWA
cd /var/www/html/config
cp config.inc.php.dist config.inc.php
# Set up database (create dvwa database, etc.)
mysql -u root -e "CREATE DATABASE dvwa;"
cd /var/www/dvwa
sudo chmod -R 777 /var/www/html/dvwa/hackable/uploads
