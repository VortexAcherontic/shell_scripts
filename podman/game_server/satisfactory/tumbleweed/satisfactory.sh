#!/usr/bin/bash
container_name=satisfactory_server

mkdir -p $PWD/game
chmod -R 777 $PWD/game
chmod 777 entrypoint.sh

podman build . -t ${container_name}

podman run -di \
-p 7777:7777/udp \
-p 15000:15000/udp \
-p 15777:15777/udp \
-v $PWD/game:/home/user/Steam:z \
--name $container_name \
--replace \
${container_name}
