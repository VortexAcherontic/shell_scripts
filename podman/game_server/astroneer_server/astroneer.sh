#!/usr/bin/bash
container_name=astroneer_server

mkdir -p $PWD/game
chmod -R 777 $PWD/game
chmod 777 entrypoint.sh

podman build . -t ${container_name}

podman run -di \
-p 8777:8777/udp \
--restart unless-stopped \
-v $PWD/game:/home/user/Steam:z \
--name $container_name \
--replace \
${container_name}
