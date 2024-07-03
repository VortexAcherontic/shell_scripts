#!/usr/bin/bash

#################################################################
# This script converts all files with a file extension          #
# contained in the formats array to Apple ProRes using ffmpeg.  #
# Note: Make sure you have a version of ffmpeg installed        #
# with support for ProRes.                                      #
# Verify using: ffmpeg -encoders | grep -i "prores_ks"          #
#################################################################

mkdir -p "$PWD/converted"
declare -a formats=("*.mkv" "*.mp4" "*.avi")

to_pro_res() {
	absolute_file="$PWD/$1"
	echo "Processing $absolute_file ..."
	ffmpeg -i "$absolute_file" \
	-c:v prores_ks \
	-c:a pcm_s16le \
	-profile:v 4 \
	-vendor apl0 \
	-bits_per_mb 8000 \
	-pix_fmt yuva444p10le \
	"$PWD/converted/${1%.*}.mov"
	echo "Done $absolute_file"
}

for format in "${formats[@]}"; do
	for file in $format; do
		if [ -f "$file" ]; then
			to_pro_res "$file"
		fi
	done
done
