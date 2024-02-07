#!/bin/bash -ex

[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/EnshroudedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous $STEAMCMD"
[ -z "$BETA" ] || STEAMCMD="$STEAMCMD -beta experimental"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update 2278520 +quit"

mkdir -p "$GAMEDIR/Logs"

#rm -f /tmp/.X1-lock
#Xvfb :1 -screen 0 800x600x24 &
#export WINEDLLOVERRIDES="mscoree,mshtml="
#export DISPLAY=:1

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

wine ./enshrouded_server.exe "$@"
