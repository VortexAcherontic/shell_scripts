#!/usr/bin/bash
container_name="sauerbraten_server"
podman build . -t ${container_name}

podman run --name ${container_name} \
	-e SB_SERVERDESC="Cube Horizon" \
	-e SB_PUBLICSERVER=0 \
	-e SB_UPDATEMASTER=0 \
	-e SB_MAXCLIENTS=32 \
	-e SB_SERVERBOTLIMIT=16 \
	-p 28785:28785/tcp \
	-p 28785:28785/udp \
	-p 28786:28786/tcp \
	-p 28786:28786/udp \
	-d ${container_name}
