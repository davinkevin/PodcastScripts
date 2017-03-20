#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	/home/$USER/scripts/ffmpeg-static/ffmpeg -y -v error -i $2 -acodec copy "/home/kevin/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')/$1 - $Date.mp3"
done
