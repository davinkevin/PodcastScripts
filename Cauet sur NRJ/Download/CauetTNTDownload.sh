#!/bin/bash

NRJChannel="auto:22";
NRJProgram=8536
IP=`/sbin/ifconfig eth1 | grep 'inet adr:' | cut -d: -f2 | awk '{ print $1}'`
freeHDHomerun=0
freeHDHomerunTuner=0

while [  true ]; do
	HDHomerunDevice=`hdhomerun_config discover | perl -pe "s@hdhomerun device ([0-9]*[A-Z].[^ ]*).*@\1@g"`
	for hdhomerun in $HDHomerunDevice; do 
	    echo HD Homerun : $hdhomerun
		for TUNER in 0 1
		do
			echo /tuner$TUNER/
			currentTunerState=`hdhomerun_config $hdhomerun  get /tuner$TUNER/status`
			if [[ "$currentTunerState" == *ch=none* ]]; then
	  			echo "is availaible";
				freeHDHomerun=$hdhomerun
				freeHDHomerunTuner=$TUNER
			fi
		done
	done

	if [ $freeHDHomerun -eq 0 ]; then 
		echo "Pas de tuner disponible - recquisition du dernier tuner testé"
		freeHDHomerun=$hdhomerun
		freeHDHomerunTuner=$TUNER;
	fi

		echo $freeHDHomerun -  $freeHDHomerunTuner

		Date=`date --date now '+%Y-%m-%d - %H-%M-%S'`
		cvlc udp://@:1234 --sout "/home/$USER/Cauet/Cauet via TNT - $Date.mp3" & &> /dev/null
		sleep 5
		PIDcVLC=`ps ax | grep vlc | grep -v grep  | perl -pe "s@^([^ ]*).*@\1@g"`
		hdhomerun_config $freeHDHomerun set /tuner$freeHDHomerunTuner/channel $NRJChannel
		hdhomerun_config $freeHDHomerun set /tuner$freeHDHomerunTuner/program $NRJProgram
		hdhomerun_config $freeHDHomerun set /tuner$freeHDHomerunTuner/target $IP:1234
		hdhomerun_config 11106C06 get /tuner0/status
	
		while [ `hdhomerun_config $freeHDHomerun get /tuner$freeHDHomerunTuner/program` -eq $NRJProgram ]; 
		do 
			#echo "Attente de 60 sec";
			sleep 60;
		done 
		kill -9 PIDcVLC
done	
