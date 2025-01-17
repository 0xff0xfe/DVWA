#!/bin/bash
# Install Apache, PHP, and MySQL for DVWA
apt-get update
apt-get install -y apache2 php mysql-server php-mysqli git
sudo chmod -R 777 /var/www/html/dvwa
