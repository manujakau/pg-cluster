#!/bin/bash
hostnamectl set-hostname pgapp

sudo apt-get -y update
sudo apt-get install apache2 \
                      php \
                      libapache2-mod-php \
                      php-pgsql
sudo phpenmod pdo_pgsql

password="admin"
sudo useradd ansadmin
yes $password | sudo passwd ansadmin
sudo usermod -aG postgres ansadmin
sudo echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl reload sshd