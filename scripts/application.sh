#!/bin/bash
hostnamectl set-hostname pgapp

sudo apt-get -y update
sudo apt-get install php \
                      apache2 \
                      libapache2-mod-php \
                      php-pgsql
sudo phpenmod pdo_pgsql

password="admin"
sudo useradd ansadmin
yes $password | sudo passwd ansadmin
sudo usermod -aG postgres ansadmin
sudo echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo mkdir /home/ansadmin
sudo usermod --shell /bin/bash --home /home/ansadmin ansadmin
sudo chown -R ansadmin:ansadmin /home/ansadmin
#sudo cp /etc/skel/.* /home/ansadmin/
sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl reload sshd