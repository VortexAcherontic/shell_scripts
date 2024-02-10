#!/bin/bash -ex
STEAMAPPID=1690800

[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/SatisfactoryDedicatedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType +login anonymous"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update $STEAMAPPID +quit"

mkdir -p "$GAMEDIR/Logs"

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

sh ./FactoryServer.sh
