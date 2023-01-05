#!/usr/bin/bash
##################################################################################################
# This script mutes a specifig part of the audio track of a given video.                         #
# By this it first extracts the audio and uses a filter to set the volume to 0 for the specified #
# section.                                                                                       #
# Then it replaces the audio track of the original video with the muted one.                     #
# This methods needs to only re-enmcode the changed audio but keeps the video file as it.        #
#                                                                                                #
# Source:                                                                                        #
# https://superuser.com/questions/1201406/how-to-use-ffmpeg-to-mute-specific-sections-of-a-video #
##################################################################################################
extract_audio() {
	ffmpeg -i "$1" -vn -acodec copy "$PWD/muted/${1%.*}.opus"
}

mute_audio() {
	ffmpeg -i "$PWD/muted/${1%.*}.opus" -af "volume=enable='between(t,$2,$3)':volume=0" "$PWD/muted/${1%.*}_muted.opus"
}

replace_audio() {
	ffmpeg -i "$1" -i "$PWD/muted/${1%.*}_muted.opus" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$PWD/muted/${f%.*}_muted.mkv"
}

clean_up() {
	rm "$PWD/muted/${1%.*}_muted.opus"
	rm "$PWD/muted/${1%.*}.opus"
}

# Must be in seconds
# Example:
# FROM=24367 -> 6:46:07 (h:mm:ss)
# TO=24398 -> 6:46:38 (h:mm:ss)
FROM=0
TO=0

mkdir -p "$PWD/muted"
for f in *; do
	if [ -f "$f" ]; then
		echo "Processing $f ..."
		extract_audio "$f"
		mute_audio "$f" $FROM $TO
		replace_audio "$f"
		clean_up "$f"
	fi
done
