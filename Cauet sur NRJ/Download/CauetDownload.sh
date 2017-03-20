#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	wget $2 -O "/home/kevin/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')/$1 - $Date.mp3" -a "/dev/null"
done
