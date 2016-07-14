#!/bin/bash 
while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	#mplayer -dumpfile "/home/$USER/Cauet/$1 - $Date.mp2" -aid 1006 -dumpaudio "rtsp://mafreebox.free.fr/fbxtv_pub/stream?namespace=1&service=100011" >> "/home/$USER/scripts/$1.log" 2>&1
	/home/$USER/scripts/ffmpeg-static/ffmpeg -v "quiet" -i "rtsp://mafreebox.free.fr/fbxtv_pub/stream?namespace=1&service=100011" -acodec copy "/home/$USER/Cauet/$1 - $Date.mp2"
done
