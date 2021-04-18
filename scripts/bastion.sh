#!/bin/bash
hostnamectl set-hostname bastion
yum update -y && yum upgrade -yum
yum autoremove -y