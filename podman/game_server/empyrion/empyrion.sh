#!/usr/bin/bash
container_name=empyrion_server

mkdir -p $PWD/game
chmod -R 777 $PWD/game
chmod 777 entrypoint.sh

podman build . -t ${container_name}

podman run -di \
-p 30000:30000/udp \
-p 30001:30001/udp \
-p 30003:30003/udp \
--restart unless-stopped \
-v $PWD/game:/home/user/Steam:z \
--name empyrion_server \
${container_name}
