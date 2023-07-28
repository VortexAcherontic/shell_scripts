#!/usr/bin/bash
container_name=minecraft_server
mkdir -p $PWD/game
chmod -R 777 $PWD/game

podman run \
-p 25565:25565 \
-p 4445:4445 \
-p 8123:8123 \
-v $PWD/game:/data:z \
--env-file $PWD/env.list \
--name ${container_name} \
-d cmunroe/bukkit:latest
