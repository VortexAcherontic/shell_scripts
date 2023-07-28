#!/usr/bin/bash
port=27960
mkdir -p $PWD/game
chmod -R 777 $PWD/game
podman run -d \
-e "OA_STARTMAP=dm4ish" \
-e "OA_PORT=$port" \
-p $port:$port/udp \
-v $PWD/game:/data:z \
--name openarena_server \
sago007/openarena
