#!/usr/bin/bash
container_name=enshrouded_server

mkdir -p $PWD/game
chmod -R 777 $PWD/game
chmod 777 entrypoint.sh

podman build . -t ${container_name}

podman run -di \
-p 15637:15637/udp \
-p 15637:15637/tcp \
-p 15636:15636/udp \
-p 15636:15636/tcp \
--restart unless-stopped \
-v $PWD/game:/home/user/Steam:z \
--name $container_name \
${container_name}
