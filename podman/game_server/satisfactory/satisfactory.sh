#!/usr/bin/bash
container_name=satisfactory_server
mkdir -p $PWD/game/config
mkdir -p $PWD/game/steam
chmod -R 777 $PWD/game

podman pull wolveix/satisfactory-server:dev

podman run -d \
--name=${container_name} \
-h satisfactory-server \
-e MAXPLAYERS=4 \
-e PGID=1000 \
-e PUID=1000 \
-e STEAMBETA=false \
-v $PWD/game/config:/config:z \
-v $PWD/game/steam:/home/steam/.steam:z \
-m 16G --memory-reservation=12G \
-p 7777:7777/udp \
-p 15000:15000/udp \
-p 15777:15777/udp \
--replace \
wolveix/satisfactory-server:dev
