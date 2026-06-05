#!/bin/bash
apt-get update -y
apt-get install -y docker.io
systemctl enable docker
systemctl start docker

docker login ${acr_login_server} -u ${acr_username} -p ${acr_password}
docker pull ${acr_login_server}/app:${image_tag}

docker run -d \
  --name app \
  --restart always \
  -p 80:3000 \
  -e ENVIRONMENT=${environment} \
  -e APP_VERSION=${image_tag} \
  ${acr_login_server}/app:${image_tag}
