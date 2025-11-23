#!/bin/bash
 
DIR_TO_WATCH="$HOME/.var/app/com.valvesoftware.Steam/Desktop"
APPLICATION_DIR="$XDG_DATA_HOME/applications/"

move_files(){
    mv "$1" "$2"
}

process_files(){
    for filename in ${DIR_TO_WATCH}/*
    do
        sed -i 's/Exec=steam/Exec=xdg-open/' "${filename}"
        sed -i 's/Icon=steam/Icon=com.valvesoftware.Steam/' "${filename}"
        move_files "${filename}" "${APPLICATION_DIR}"
    done
}

trap "echo Exited!; exit;" SIGINT SIGTERM
while [[ 1=1 ]]
do
  watch --chgexit -n 1 "ls --all -l --recursive --full-time ${DIR_TO_WATCH} | sha256sum" && process_files
  sleep 60
done