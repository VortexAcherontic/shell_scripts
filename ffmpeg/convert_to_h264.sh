#!/usr/bin/bash
##########################################################
# Converts all files in a directory using ffmpeg into    #
# h264 video streams while keeping all audio and         #
# subtitles as it.                                       #
# Usefull to convert a ripped DVD/BluRay to make it      #
# better play on a Raspberry Pi for example as some      #
# BluRays come with a VC1 video codec which the Pi can't #
# play hardware accelerated.                             #
# Notice: If you happen to convert a VC1 video file make #
# sure your build of ffmpeg was compiled with this       #
# proprietary format enabled.				 #
##########################################################
mkdir -p "$PWD/converted"
for f in *; do
	if [ -f "$f" ]; then
		echo "Processing $f ..."
		ffmpeg -i "$f" \
		-map 0 \
        	-c:v h264 \
        	-c:a copy \
        	-c:s copy \
        	"$PWD/converted/${f%.*}.mkv"
	fi
done
