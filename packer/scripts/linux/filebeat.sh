#!/bin/bash

wget -O - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

add-apt-repository "deb https://artifacts.elastic.co/packages/7.x/apt stable main"

apt-get install -y -qq filebeat=${FILEBEAT_VERSION}

apt-mark hold filebeat

sed -i -e 's|output.*|output.logstash:|g' -e "/output.*/{n;n;s|hosts:.*|hosts: [\"${LS_SERVER}\"]|;}" /etc/filebeat/filebeat.yml

systemctl enable filebeat
