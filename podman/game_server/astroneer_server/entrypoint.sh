#!/bin/bash -ex
STEAMAPPID=728470

[ "$UID" != 0 ] || {
    mkdir -p ~user/Steam
    chown user: ~user/Steam
    runuser -u user "$0" "$@"
    exit 0
}

GAMEDIR="$HOME/Steam/steamapps/common/ASTRONEER Dedicated Server"

cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"

# eval to support quotes in $STEAMCMD
eval "$STEAMCMD +app_update $STEAMAPPID +quit"

mkdir -p "$GAMEDIR/Logs"

rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export DISPLAY=:1

cd "$GAMEDIR"

[ "$1" = "bash" ] && exec "$@"

rm -rf $HOME/.wine
wineboot
wine ./AstroServer.exe
