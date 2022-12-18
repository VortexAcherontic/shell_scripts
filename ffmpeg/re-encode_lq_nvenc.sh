#!/usr/bin/bash
#########################################################
# Converts all files in a directory using ffmpeg        #
# With a 5000k bitrate (1k lower then default Twitch    #
# bitrate). This is ment for Streams still larger than  #
# 20GB if using the SQ re-encode script                 #
#########################################################

mkdir -p "$PWD/converted"
for f in *; do
	if [ -f "$f" ]; then
		echo "Processing $f ..."
		ffmpeg -threads 1 \
        -hwaccel nvdec \
        -hwaccel_device 0 \
        -hwaccel_output_format cuda \
        -i "$f" \
        -c:v h264_nvenc \
        -gpu:v 0 \
        -cq:v 21 \
        -rc:v vbr \
        -tune:v ll \
        -preset:v p1 \
        -b:v 0 \
        -maxrate:v 5000k \
        -bufsize:v 5000K \
        -c:a aac \
        -b:a 160k \
        -movflags +faststart \
        -f mp4 "$PWD/converted/${f%.*}.mp4"
	fi
done 
