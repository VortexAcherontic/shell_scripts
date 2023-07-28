servermap=TheIsland
server_name=ark_server_${servermap}
steam_dir=$PWD/${servermap}/steam
game_dir=$PWD/${servermap}/game
mkdir -p $steam_dir
mkdir -p $game_dir
chmod -R 777 $steam_dir
chmod -R 777 $game_dir

podman run -d \
-p 27015:27015 -p 27015:27015/udp \
-p 7778:7778 -p 7778:7778/udp \
-p 7777:7777 -p 7777:7777/udp \
-v $steam_dir:/home/steam/.steam:z \
-v $game_dir:/ark:z \
-v /run/podman/podman.sock:/var/run/docker.sock:Z \
--name $server_name \
-e am_ark_SessionName="Ark Horizon ${servermap}" \
-e am_serverMap="${servermap}" \
-e am_ark_ServerAdminPassword="1234IsABadPassword" \
-e am_ark_MaxPlayers=70 \
-e am_ark_ServerPVE=True \
-e am_arkwarnminutes=15 \
-e am_arkflag_crossplay=true \
-e am_ark_GameModIds=895711211,768494420 \
-e am_ark_automanagedmods \
-e am_ark_NoBattlEye \
thmhoag/arkserver
