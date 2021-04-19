#!/bin/bash
hostnamectl set-hostname pgslave

sudo apt-get -y update
sudo apt-get -y install nano wget
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
apt-get update -y
apt-get -y install postgresql-13
sudo /etc/init.d/postgresql start
sudo systemctl is-enabled postgresql
sudo /etc/init.d/postgresql stop

password="admin"
sudo useradd ansadmin
yes $password | sudo passwd ansadmin
sudo usermod -aG postgres ansadmin
sudo echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo mkdir /home/ansadmin
sudo usermod --shell /bin/bash --home /home/ansadmin ansadmin
sudo chown -R ansadmin:ansadmin /home/ansadmin
sudo cp /etc/skel/.* /home/ansadmin/
sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl reload sshd