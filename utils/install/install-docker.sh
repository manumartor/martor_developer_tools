#!/bin/bash

#install package
apt install -y docker.io docker-compose

#configure
systemctl enable --now docker
usermod -aG docker $(logname)
chown $(logname):$(logname) /var/run/docker.sock

echo ""
echo "docker installed!!"
echo ""
exit 0
