#!/bin/bash

killall mplayer
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
cd "/home/${USER}/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')"

for mp2file in `ls -tr | grep mp2 | tail -n 1`; do
	#echo "$mp2file"
	mp3file=`echo $mp2file | sed -e "s@\([^\.]\).mp2@\1.mp3@g"`
	#echo $mp3file
	lame --mp2input -b 192 -q0 "$mp2file" "$mp3file"
done

for aacfile in `ls -tr | grep aac | tail -n 2`; do
        #echo "$mp2file"
        mp3file=`echo "$aacfile" | sed -e "s@\([^\.]\)\.aac@\1.mp3@g"`
        #echo $mp3file
	/home/$USER/scripts/ffmpeg-static/ffmpeg -i "$aacfile" -c:a libmp3lame -ac 2 -q:a 2 "$mp3file"
done

IFS=$SAVEIFS
