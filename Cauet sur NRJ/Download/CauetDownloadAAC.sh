#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	/home/$USER/scripts/ffmpeg-static/ffmpeg -v error -y -i $2 -acodec copy "/home/kevin/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')/$1 - $Date.aac"
done
