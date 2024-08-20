#!/usr/bin/bash
container_name=enshrouded_server

mkdir -p $PWD/game
chmod -R 777 $PWD/game

podman run -di \
-p 15637:15637/udp \
-p 15637:15637/tcp \
-p 15636:15636/udp \
-p 15636:15636/tcp \
-e SERVER_NAME="Enshrouded Docker Server" \
-e UPDATE_CRON="*/30 * * * *" \
-e PUID=4711 \
-e PGID=4711 \
-e SERVER_IP="0.0.0.0" \
--restart unless-stopped \
-v $PWD/game:/opt/enshrouded:z \
--name $container_name \
mornedhels/enshrouded-server
