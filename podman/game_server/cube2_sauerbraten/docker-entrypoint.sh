#!/usr/bin/env sh
set -e

WORKDIR="/sauerbraten"
SERVER="$WORKDIR/bin_unix/linux_64_server"
CONFIG="$WORKDIR/server-init.cfg"

# Start from clean configuration each time.
cp "$CONFIG.orig" "$CONFIG"

# Define a helper to easily rewrite settings.
configure() {
  if [ ${1} ] && [ "$(echo $2 | tr -d '"' )" ]; then
    echo "SETTING -> ${1} ${2}"
    sed -i -E "s;^(\/\/\s)?(${1}).*;\2 ${2};" "${CONFIG}"
  fi
}

# Check each and every ENV variable and rewrite config if set.
configure serverdesc         "\"${SB_SERVERDESC}\""
configure serverpass         "\"${SB_SERVERPASS}\""
configure adminpass          "\"${SB_ADMINPASS}\""
configure serverauth         "\"${SB_SERVERAUTH}\""
configure servermotd         "\"${SB_SERVERMOTD}\""
configure maxclients         "${SB_MAXCLIENTS}"
configure serverbotlimit     "${SB_SERVERBOTLIMIT}"
configure publicserver       "${SB_PUBLICSERVER}"
configure updatemaster       "${SB_UPDATEMASTER}"
configure restrictdemos      "${SB_RESTRICTDEMOS}"
configure maxdemosize        "${SB_MAXDEMOSIZE}"
configure maxdemos           "${SB_MAXDEMOS}"
configure autorecorddemo     "${SB_AUTORECORDDEMO}"
configure restrictpausegame  "${SB_RESTRICTPAUSEGAME}"
configure restrictgamespeed  "${SB_RESTRICTGAMESPEED}"
configure lockmaprotation    "${SB_LOCKMAPROTATION}"
configure persistteams       "${SB_PERSISTTEAMS}"
configure overtime           "${SB_OVERTIME}"
configure regenbluearmour    "${SB_REGENBLUEARMOUR}"

# Change into the workdir so SB picks up $CONFIG.
cd $WORKDIR
$SERVER
