#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	wget $2 -O "/home/$USER/Cauet/$1 - $Date.mp3" -a "/home/$USER/scripts/$1.log"

done
