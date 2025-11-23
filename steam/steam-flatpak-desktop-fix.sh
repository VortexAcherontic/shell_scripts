#!/bin/sh

##########################################################################
# How to use:                                                            #
# - Mark this file as executable                                         #
#   - chmod +x /path/to/file/                                            #
#   - Right-Click -> Properties -> Permissions -> Mark as Executable     #
# - Add this file to your desktop environments autostart                 #
# - Profit                                                               #
##########################################################################

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
    for filename in "${DIR_TO_WATCH}"/*; do
        [[ -f "$filename" ]] || continue
        sed -i 's/Exec=steam/Exec=xdg-open/' "${filename}"
        move_files "${filename}" "${APPLICATION_DIR}"
    done
    copy_icons
    update-desktop-database
}

trap "echo Exited!; exit;" SIGINT SIGTERM
while [[ 1=1 ]]
do
  process_files
  sleep 60
done