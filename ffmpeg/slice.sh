#!/usr/bin/bash
###########################################################
# Slices all video in the current directory in two        #
# at the given TIME mark but keeps video and audio stream #
# in their original qualtiy and keeps the original files  #
###########################################################

mkdir -p "$PWD/sliced"
TIME=$1
for f in *; do
	if [ -f "$f" ]; then
		echo "Processing $f ..."
        	ffmpeg -i "$f" \
		-c copy \
        	-to $TIME "$PWD/sliced/${f%.*}_start.${f##*.}"

	        ffmpeg -i "$f" \
	        -c copy \
	        -ss $TIME "$PWD/sliced/${f%.*}_end.${f##*.}"
	fi
done 
