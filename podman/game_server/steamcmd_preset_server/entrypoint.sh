#!/bin/bash -ex
STEAMAPPID=0000000

[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/EnshroudedServer"

cd "$HOME"
# STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"
# STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType +login anonymous"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update $STEAMAPPID +quit"

mkdir -p "$GAMEDIR/Logs"

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

# wine ./server.exe "$@"
# ./server.bin
