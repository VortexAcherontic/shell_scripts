#!/usr/bin/bash
###############################################################
# usage:						      #
# ./trim_upscale start[hh:mm:ss] end[hh:mm:ss] width[integer] #
# Cuts a segment of a video from <start> to <end> and         #
# upscales it to <width> while keeping the original           #
# aspect ratio of the video                                   #
###############################################################

working_dir="$PWD/processed"
mkdir -p "$working_dir"
params_set=0

if [ -z ${1+x} ]; then
	echo "start time is not set (hh:mm:ss)"
else
	params_set=$params_set+1
fi

if [ -z ${2+x} ]; then
	echo "end time is not set (hh:mm:ss)"
else
	params_set=$params_set+1
fi

if [ -z ${3+x} ]; then
	echo "scale width is not set (integer)"
else
	params_set=$params_set+1
fi

if [ $params_set == 3 ]; then
	for f in *; do
		if [ -f "$f" ]; then
			echo "Processing $f ..."
			ffmpeg -i "$f" \
			-c copy \
			-ss $1 \
			-to $2 "$working_dir/${f%.*}_trimmed.${f##*.}"
			
			ffmpeg -i "$working_dir/${f%.*}_trimmed.${f##*.}" \
			-c:v h264 \
			-c:a copy \
			-vf scale=-1:$3:flags=fast_bilinear "$working_dir/${f%.*}_scaled.${f##*.}"
		fi
	done 
fi
