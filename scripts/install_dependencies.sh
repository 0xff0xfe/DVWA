#!/bin/bash
# Install Apache, PHP, and MySQL for DVWA
apt-get update
apt-get install -y apache2 php mysql-server php-mysqli git
chown -R www-data:www-data /var/www/dvwa
