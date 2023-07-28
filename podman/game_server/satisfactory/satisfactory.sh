#!/usr/bin/bash
mkdir -p $PWD/game/config
mkdir -p $PWD/game/steam
chmod -R 777 $PWD/game

podman run -d \
--name=satisfactory_server \
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
wolveix/satisfactory-server:dev
