#!/bin/bash 

while [  true ]; do
	Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
	mimms mms://vipnrj.yacast.net/encodernrj_sat?MSWMExt=.asf "/home/$USER/Cauet/$1 - $Date.wma" >> "/home/$USER/scripts/$1.log" 2>&1
done
