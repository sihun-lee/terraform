#!/bin/bash

sudo apt update -y
sudo apt install git curl zip unzip -y
cd /home/ubuntu
git clone https://github.com/sihun-lee/aws-project.git
sudo chown -R ubuntu:ubuntu aws-project

cd /home/ubuntu/aws-project

chmod u+x install-docker.sh && sudo ./install-docker.sh
chmod u+x install-docker-compose.sh && sudo ./install-docker-compose.sh

sudo docker-compose up -d --build