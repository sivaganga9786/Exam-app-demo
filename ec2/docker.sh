#!/bin/bash

exec > /var/log/docker.log 2>&1
set -xe

sudo apt update -y
# Install required packages
sudo apt-get install -y ca-certificates curl

# Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
docker --version


sudo usermod -aG docker jenkins

sudo systemctl restart jenkins

sudo -u jenkins docker ps 


# Update & Install Python pip 
sudo apt-get update
sudo apt-get install -y python3-venv python3-pip
sudo apt install ansible-core -y
# Verify Ansible installation
ansible --version
 
# Install docker-compose on your Jenkins server:
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
docker compose version
