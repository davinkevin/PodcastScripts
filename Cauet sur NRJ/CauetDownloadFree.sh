#!/bin/bash 
while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	mplayer -dumpfile "/home/###/Cauet/$1 - $Date.mp2" -aid 1006 -dumpaudio "rtsp://mafreebox.free.fr/fbxtv_pub/stream?namespace=1&service=100011" >> "/home/###/scripts/$1.log" 2>&1
done
