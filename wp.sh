#!/bin/bash

# Variables
path="/var/www/html"
MYSQL=`which mysql`
SQLPASS=$1
DB_NAME="wordpress"
USER="azureuser"
DB_PASS="ChangeThisPa$$Werd"

# Set MYSQL root password
export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.7 mysql-server/root_password password $SQLPASS | debconf-set-selections
echo mysql-server-5.7 mysql-server/root_password_again password $SQLPASS | debconf-set-selections

# Install packages
apt-get install apache2 mysql-server php php-mysql libapache2-mod-php -y

# Download WordPress latest tarball and unzip it
wget https://wordpress.org/latest.tar.gz -P /tmp
tar xzf /tmp/latest.tar.gz -C $path

# Set User:Group, perms, and move files for WordPress installation
chown -R root:root $path/wordpress
find $path -type f -exec chmod 644 {} \;
find $path -type d -exec chmod 777 {} \;
mv $path/wordpress/* $path/
mv $path/wp-config-sample.php $path/wp-config.php

# Functions

# Create Database for WordPress
ok() { echo -e '\e[32m'$1'\e[m'; } # Green


Q1="CREATE DATABASE IF NOT EXISTS $DB_NAME;"
Q2="GRANT ALL ON *.* TO '$USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"


$MYSQL -uroot -p$SQLPASS -e "$SQL"

ok "Database $DB_NAME and user $USER created with a password $DB_PASS"

# Find and replace for wp-config.php
sed -i "s/database_name_here/$DB_NAME/g ; s/username_here/$USER/g ; s/password_here/$DB_PASS/g" /var/www/html/wp-config.php


echo "Script Complete"
