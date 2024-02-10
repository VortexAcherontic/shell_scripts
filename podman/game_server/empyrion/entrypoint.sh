#!/bin/bash -ex

[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/DedicatedServer"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update 530870 +quit"

mkdir -p "$GAMEDIR/Logs"

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:1

cd "$GAMEDIR"

wine ./EmpyrionDedicated.exe -batchmode -nographics -logFile Logs/current.log
