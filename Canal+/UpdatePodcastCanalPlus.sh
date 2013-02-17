#!/bin/bash

#Example : 
#./canalplusV2.sh "Nom Du Podcast" "terme_à_rechercher" "type" "nombre_de_jour_à_conserver"

# Exemlple pour le petit journal : 
/home/$USER/scripts/canalplusV2.sh "Le Petit Journal" petit QUOTIDIEN 7

# D'autre exemples en vracs :
/home/$USER/scripts/canalplusV2.sh "Le Zapping" zapping EMISSION 10
/home/$USER/scripts/canalplusV2.sh "Zapsport" zapsport EMISSION 10
/home/$USER/scripts/canalplusV2.sh "Les Guignols" guignols QUOTIDIEN 7
/home/$USER/scripts/canalplusV2.sh "JDJV" JDJV EMISSION 4 

killall rtmpdump canalplusV2.sh UpdatePodcastCanalPlus.sh #Kill des process restant actif après l'exécution
