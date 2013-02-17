#!/bin/bash

serveur="http://url/du/dossier/local/des/podcast/du/serveur/http"

nomComplet=$1
nomDeRecherche=$2
nomPodcast="Canal+ - $nomComplet"
nomPodcastHTML=`echo $nomPodcast | sed 's@ @%20@g'`
category=$3
nombreEpisodes=$4
if [[ ! -z "$5" ]]; then
        forceDownload=true;
else 
        forceDownload=false;
fi

echo "/home/$USER/Podcast/Canal+ - $nomComplet"

if [ ! -d "/home/$USER/Podcast/Canal+ - $nomComplet" ]; then
    mkdir "/home/$USER/Podcast/Canal+ - $nomComplet"
fi
cd "/home/$USER/Podcast/Canal+ - $nomComplet";
#wget "http://pipes.yahoo.com/pipes/pipe.run?_id=042fa84633887b7b7505b94b1ea6ae9e&_render=rss&category=${category}&searchEmission=${nomDeR$
wget -q "www.canalplus.fr/rest/bootstrap.php?/bigplayer/search/`echo $nomComplet | sed 's@ @%20@g'`" -O "${nomPodcast}FromSite.xml"
java -jar /usr/local/bin/saxon9he.jar "${nomPodcast}FromSite.xml" /home/$USER/scripts/CanalPlusXSLT.xslt title="$nomComplet" serverlocation="$serveur" -o:"${nomPodcast}.xml"

  
# Téléchargement des n derniers épisodes : 
for nomDuFichier in $(cat "${nomPodcast}.xml" | grep -e "rtmp://[^<]*" -o | uniq | head -n $nombreEpisodes )
do 
        #echo $nomDuFichier
        #urlDuFichier=`xmlstarlet sel -t -m "//item[./link[contains(., '$i')]]" -v "link" "${nomPodcast}FromSite.xml"`
        echo ${nomDuFichier##*/}
        if [[ ! -s ${nomDuFichier##*/} ]] ; then
                echo "Téléchargement de ${nomDuFichier##*/}"
                rtmpdump -r "$nomDuFichier" -o ${nomDuFichier##*/};
        fi
        if $forceDownload; then
                echo "Force Téléchargement de ${nomDuFichier##*/}"
                #rtmpdump -r "$nomDuFichier" -o ${nomDuFichier##*/};
        fi
        if [ -f "${nomDuFichier##*/}" ] 
        then 
                echo Ajouter dans le xml de l\'épisode ${nomDuFichier##*/}
                xmlstarlet ed -L -s "//item[./link[contains(., '$nomDuFichier')]]" -t elem -n enclosure -v "" "${nomPodcast}.xml"
                xmlstarlet ed -L -s "//item[./link[contains(., '$nomDuFichier')]]/enclosure" -t attr -n url -v "${serveur}/${nomPodcastHTML}/${nomDuFichier##*/}" "${nomPodcast}.xml" >> /dev/null
                xmlstarlet ed -L -s "//item[./link[contains(., '$nomDuFichier')]]/enclosure" -t attr -n length -v "`stat -c%s ${nomDuFichier##*/}`" "${nomPodcast}.xml" >> /dev/null
                xmlstarlet ed -L -s "//item[./link[contains(., '$nomDuFichier')]]/enclosure" -t attr -n type -v "video/mp4" "${nomPodcast}.xml" >> /dev/null
        fi
done

for nomDuFichier in $(cat "${nomPodcast}.xml" | grep -e "rtmp://[^<]*" -o | uniq | tail -n +$((nombreEpisodes+1)))
do 
        if [ -f ${nomDuFichier##*/} ]; then
                echo Suppression de ${nomDuFichier##*/}
                rm ${nomDuFichier##*/}                
        fi
done
