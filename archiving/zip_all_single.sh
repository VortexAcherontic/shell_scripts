#!/usr/bin/bash
###############################################################
# Compress all files in a directory as a single zip file each #
# With the highes possible ZIP conform crompression           #
# Multi threaded!                                             #
###############################################################

for file in *
do
7z a -mm=Deflate -mfb=258 -mpass=15 -r "${file%.*}.zip" "$file" &
done
