#!/bin/bash -eux

add-apt-repository "deb https://mirror.yandex.ru/ubuntu/ $(lsb_release -cs) universe multiverse main"
add-apt-repository "deb https://mirror.yandex.ru/ubuntu/ $(lsb_release -cs)-updates universe multiverse main"
add-apt-repository "deb https://mirror.yandex.ru/ubuntu/ $(lsb_release -cs)-security universe multiverse main"

# apt-get update

apt-get -y dist-upgrade

sed -i 's|^#PermitRootLogin.*|PermitRootLogin no|g' /etc/ssh/sshd_config
sed -i '1 s|/bin/bash|/usr/sbin/nologin|' /etc/passwd

echo "${SSH_USERNAME} ALL=(ALL:ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/local
chmod 0440 /etc/sudoers.d/local
