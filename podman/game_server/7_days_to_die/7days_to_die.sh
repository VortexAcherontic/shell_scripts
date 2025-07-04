#!/usr/bin/bash
container_name=7_days_to_die

mkdir -p $PWD/game
mkdir -p $PWD/game/world
mkdir -p $PWD/game/lgsm_config
mkdir -p $PWD/game/server_files
mkdir -p $PWD/game/logs
mkdir -p $PWD/game/backup
chmod -R 777 $PWD/game

podman run -di \
-p 26900:26900/tcp \
-p 26900:26900/udp \
-p 26901:26901/udp \
-p 26902:26902/udp \
-p 8080:8080/tcp \
-p 8081:8081/tcp \
-p 8082:8082/tcp \
-e LINUXGSM_VERSION=v24.3.4 \
-e START_MODE=1 \
-e VERSION=stable \
-e PUID=1000 \
-e PGID=1000 \
-e TimeZone=Europe/Berlin \
-e TEST_ALERT=NO \
-e UPDATE_MODS=NO \
-e MODS_URLS="" \
-e ALLOC_FIXES=NO \
-e ALLOC_FIXES_UPDATE=NO \
-e UNDEAD_LEGACY=NO \
-e UNDEAD_LEGACY_VERSION=stable \
-e UNDEAD_LEGACY_UPDATE=NO \
-e DARKNESS_FALLS=NO \
-e DARKNESS_FALLS_UPDATE=NO \
-e DARKNESS_FALLS_URL=False \
-e CPM=NO \
-e CPM_UPDATE=NO \
-e BEPINEX=NO \
-e BEPINEX_UPDATE=NO \
-e BACKUP=YES \
-e BACKUP_HOUR=5 \
-e BACKUP_MAX=7 \
-e MONITOR=NO \
--restart unless-stopped \
-v $PWD/game:/opt/enshrouded:z \
-v $PWD/game/world:/home/sdtdserver/.local/share/7DaysToDie:z \
-v $PWD/game/lgsm_config:/home/sdtdserver/lgsm/config-lgsm/sdtdserver:z \
-v $PWD/game/server_files:/home/sdtdserver/serverfiles:z \
-v $PWD/game/logs:/home/sdtdserver/log:z \
-v $PWD/game/backup:/home/sdtdserver/lgsm/backup:z \
--name $container_name \
vinanrra/7dtd-server
