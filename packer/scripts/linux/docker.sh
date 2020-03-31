#!/bin/bash

wget -O - https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get install -y -qq docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION} containerd.io docker-compose=${DOCKER_COMPOSE_VERSION}

apt-mark hold docker-ce docker-ce-cli containerd.io docker-compose

