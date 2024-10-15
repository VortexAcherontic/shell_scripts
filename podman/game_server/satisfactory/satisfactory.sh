#!/usr/bin/bash
container_name=satisfactory_server
mkdir -p $PWD/game/config
mkdir -p $PWD/game/steam
chmod -R 777 $PWD/game

podman pull wolveix/satisfactory-server:latest

podman run -d \
--name=${container_name} \
-h satisfactory-server \
-e MAXPLAYERS=4 \
-e PGID=1000 \
-e PUID=1000 \
-e STEAMBETA=false \
-e ROOTLESS=false \
-v $PWD/game/config:/config:z \
-m 16G \
--memory-reservation=12G \
-p 7777:7777/udp \
-p 7777:7777/tcp \
--replace \
--restart unless-stopped \
wolveix/satisfactory-server:latest
