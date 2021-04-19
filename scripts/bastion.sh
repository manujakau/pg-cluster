#!/bin/bash
hostnamectl set-hostname bastion
yum update -y && yum upgrade -y
amazon-linux-extras install ansible2 -y

password="admin"
sudo useradd ansadmin
yes $password | sudo passwd ansadmin
sudo usermod -aG postgres ansadmin
sudo echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo mkdir /home/ansadmin
sudo usermod --shell /bin/bash --home /home/ansadmin ansadmin
sudo chown -R ansadmin:ansadmin /home/ansadmin
sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl reload sshd
yum autoremove -y