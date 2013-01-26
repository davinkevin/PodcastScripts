#!/bin/bash

#Récupération des paramètre : 
xmlParameter=$1
feedUrl=`xmlstarlet sel -t -v "//feedUrl" $xmlParameter`
podcastName=`xmlstarlet sel -t -v "//podcastName" $xmlParameter`
serverURL=`xmlstarlet sel -t -v "//serverURL" $xmlParameter`
serverLocation=`xmlstarlet sel -t -v "//serverLocation" $xmlParameter`

#Création des variables dérivées :
PodcastNameHTML=`echo $podcastName | perl -pe "s@ @%20@g"`

#Création du dossier de destination s il n existe pas
if [ ! -d "$serverLocation/$podcastName" ]; then
    mkdir "$serverLocation/$podcastName"
fi
cd "$serverLocation/$podcastName"

#Téléchargement du flux de base :
curl -s "$feedUrl" -o "$podcastName.xml"
cp "$podcastName.xml" "${podcastName}ToJuice.xml"
cp "$podcastName.xml" "${podcastName}ToItunes.xml"

#Changement du titre du Podcast : 
xmlstarlet ed -L -u "/rss/channel/title" -v "$podcastName" *.xml

#########################################################################################################
# Modification de la version pour le gestionnaire de téléchargement :									#
#########################################################################################################
# - Changer les liens qui utilise des proxys (feedburner par exemple)
if [ ! -z "`cat "$podcastName.xml" | grep feedburner:origEnclosureLink`" ]; then
	#echo FeedBurner Transformation;
	#Pour chaque Element du flux, effectuer une transformation : 
	for numElem in $(seq 1 1 `xmlstarlet sel -t -v "count(//item)" "$podcastName.xml"`)
	do 
		xmlstarlet ed -L -N feedburner="http://rssnamespace.org/feedburner/ext/1.0" \
			-u "//item[$numElem]/enclosure/@url" -v "`xmlstarlet sel -N feedburner="http://rssnamespace.org/feedburner/ext/1.0" -t -m "//item[$numElem]/feedburner:origEnclosureLink" -v "text()" "${podcastName}.xml"`" \
			-d "//item[$numElem]/feedburner:origEnclosureLink" \
			"${podcastName}ToJuice.xml"
	done
fi

#Si l'enclosure contient un media_url :
if [ ! -z "`xmlstarlet sel -t -m "//item/enclosure" -v "@url" "${podcastName}ToJuice.xml" | grep media_url`" ]; then
	#echo Réorganisation pour media_url
	for numElem in $(seq 1 1 `xmlstarlet sel -t -v "count(//item)" "$podcastName.xml"`)
	do 
		#URL Réelle :
		realUrl=`xmlstarlet sel -t -m "//item[$numElem]/enclosure" -v "@url" "${podcastName}ToJuice.xml" | perl -pe "s@.*media_url=(.*)@\1@g" | ascii2uni -a J -q`

		#Extraction si cela vient de podtrac : 
		if [[ "$realUrl" == *podtrac* ]]; then
				realUrl=`echo $realUrl | perl -pe "s@.*redirect.mp3/(.*)@http://\1@g"`
		fi
		xmlstarlet ed -L \
			-u "//item[$numElem]/enclosure/@url" -v "$realUrl" \
			"${podcastName}ToJuice.xml"
	done
fi 

#########################################################################################################
# Modification de la version lisible par les aggrégateur de flux locaux :								#
#########################################################################################################
cp "${podcastName}ToJuice.xml" "$podcastName.xml"
for numElem in $(seq 1 1 `xmlstarlet sel -t -v "count(//item)" "${podcastName}.xml"`)
do 
	fileName=`xmlstarlet sel -t -m "//item[$numElem]/enclosure" -v "@url" "${podcastName}.xml"`
	if [ -f "${fileName##*/}" ]; then 
		xmlstarlet ed -L \
			-u "//item[$numElem]/enclosure/@url" -v "$serverURL/$PodcastNameHTML/${fileName##*/}" \
			"${podcastName}.xml"
	fi
done
