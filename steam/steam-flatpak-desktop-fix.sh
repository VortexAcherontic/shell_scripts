#!/bin/bash
 
DIR_TO_WATCH="$HOME/.var/app/com.valvesoftware.Steam/Desktop"
STEAM_ICON_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/icons/"
APPLICATION_DIR="$XDG_DATA_HOME/applications/"
ICON_DIR="$XDG_DATA_HOME/"

move_files(){
    mv "$1" "$2"
}

copy_icons(){
    cp -rn "$STEAM_ICON_DIR" "$ICON_DIR"
}

process_files(){
    for filename in ${DIR_TO_WATCH}/*
    do
        sed -i 's/Exec=steam/Exec=xdg-open/' "${filename}"
        #sed -i 's/Icon=steam/Icon=com.valvesoftware.Steam/' "${filename}"
        move_files "${filename}" "${APPLICATION_DIR}"
    done
    copy_icons
}

trap "echo Exited!; exit;" SIGINT SIGTERM
while [[ 1=1 ]]
do
  watch --chgexit -n 1 "ls --all -l --recursive --full-time ${DIR_TO_WATCH} | sha256sum" && process_files
  sleep 1
done