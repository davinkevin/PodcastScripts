#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	wget $2 -O "/home/###/Cauet/$1 - $Date.mp3" -a "/home/###/scripts/$1.log"

done
