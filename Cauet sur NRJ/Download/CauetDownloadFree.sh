#!/bin/bash 
while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	/home/$USER/scripts/ffmpeg-static/ffmpeg -v error -y -i "rtsp://mafreebox.free.fr/fbxtv_pub/stream?namespace=1&service=100011" -map i:1006 -acodec copy "/home/$USER/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')/$1 - $Date.mp2"
done
