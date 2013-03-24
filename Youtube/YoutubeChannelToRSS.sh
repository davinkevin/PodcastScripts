#!/bin/bash

text_to_html() {
	text=$1
	text=${text//&/&amp;}
	text=${text// /%20}
	text=${text//#/%23}
#	text=${text//é/&#xe9;}
	echo $text
}

#Chargement des alias & cie : 
alias sed='perl -pe'
serveur="http://url/du/serveur/http"

#Mise en place des variables récupérées depuis la ligne de commande :
YoutubeUser=$1
maxDownloads=$2
title=$3

#Mise en place des variables configurées
PodcastName=`echo Youtube - $title`
PodcastNameHTML=`echo $PodcastName | perl -pe "s@ @%20@g"`

#Création du dossier de destination s il n existe pas
if [ ! -d "/home/$USER/Podcast/$PodcastName" ]; then
    mkdir "/home/$USER/Podcast/$PodcastName"
fi
cd "/home/$USER/Podcast/$PodcastName"
chmod +w *.info.json

#Récupérations des $maxDownloads derniers éléments : 
youtube-dl.py -c -w -o "%(upload_date)s-%(title)s.%(ext)s" --restrict-filenames --write-info-json --max-downloads $maxDownloads "http://www.youtube.com/user/$YoutubeUser"
#youtube-dl.py -c -w -o "%(upload_date)s-%(title)s.%(ext)s" --restrict-filenames --write-info-json --skip-download --max-downloads $maxDownloads "http://www.youtube.com/user/$YoutubeUser"
echo '<?xml version="1.0" encoding="UTF-8"?><rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" />' > "$PodcastName.xml"

#Mise en place des valeurs relatives au flux : 
curl -s "http://gdata.youtube.com/feeds/api/users/$YoutubeUser" -o "$YoutubeUser.description.xml"
xmlstarlet ed -L -s "/rss" -t elem -n "channel" -v "" \
	-s "//channel" -t elem -n "title" -v "$PodcastName" \
	-s "//channel" -t elem -n "description" -v "`xmlstarlet sel -N ns="http://www.w3.org/2005/Atom" -t -v "//ns:content" $YoutubeUser.description.xml`" \
	-s "//channel" -t elem -n "link" -v "$serveur/$PodcastNameHTML/$PodcastNameHTML.xml" \
	-s "//channel" -t elem -n "pudDate" -v "`date --rfc-2822`" \
	-s "//channel" -t elem -n image -v "" \
	-s "//channel/image" -t elem -n url -v "`xmlstarlet sel -N media="http://search.yahoo.com/mrss/" -t -v "//media:thumbnail/@url" $YoutubeUser.description.xml`" \
	-s "//channel/image" -t elem -n link -v "`xmlstarlet sel -N media="http://search.yahoo.com/mrss/" -t -v "//media:thumbnail/@url" $YoutubeUser.description.xml`" \
	-s "//channel/image" -t elem -n title -v "Youtube User Image" \
	"$PodcastName.xml"

for nomDuFichier in $(ls *.info.json -r ); do 
	#echo "$nomDuFichier"
	sed -i -e "s@\\\u\(....\)@<U\1>@g" "$nomDuFichier"
	#cat "$nomDuFichier" | grep -o -e '"upload_date": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g'
	podcastFile=${nomDuFichier%*.info.json}
	#echo File : $podcastFile
	podcastFileHTML=`text_to_html "$podcastFile"`
	#echo HTML : $podcastFileHTML
	#touch $podcastFile
#	if [ -e $podcastFile ]; then
	urlToEpisode=`echo $serveur/$PodcastNameHTML/$podcastFileHTML`
	sizeEpisode=`stat -c%s $podcastFile`
#	else 
#		urlToEpisode=`cat "$nomDuFichier" | grep -o -e '"url": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g'`
#		sizeEpisode=`cat "$nomDuFichier" | grep -o -e '"url": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g' | xargs curl -s --head | grep Content-Length | perl -pe "s@.*: (.*)@\1@g"`
#	fi

	xmlstarlet ed -L -N media="http://search.yahoo.com/mrss/" -s "//channel" -t elem -n currentitem -v "" \
		-s "//currentitem" -t elem -n title -v "`cat "$nomDuFichier" | grep -o -e '"title": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g' | ascii2uni -a A -q | xmlstarlet esc`" \
		-s "//currentitem" -t elem -n link -v "$serveur/$PodcastNameHTML/$PodcastFileHTML" \
		-s "//currentitem" -t elem -n guid -v "$serveur/$PodcastNameHTML/$podcastFileHTML" \
		-s "//currentitem" -t elem -n description -v "`cat "$nomDuFichier" | grep -o -e '"description": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g' | ascii2uni -a A -q | xmlstarlet esc`" \
		-s "//currentitem" -t elem -n enclosure -v "" \
		-s "//currentitem/enclosure" -t attr -n url -v "$urlToEpisode" \
		-s "//currentitem/enclosure" -t attr -n length -v "$sizeEpisode" \
		-s "//currentitem/enclosure" -t attr -n type -v "video/${podcastFile#*.*}" \
		-s "//currentitem" -t elem -n pubDate -v "`cat "$nomDuFichier" | grep -o -e '"upload_date": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g' | xargs date --rfc-2822 -d`" \
		-s "//currentitem" -t elem -n "thumbnail" -v "" \
        -s "//currentitem/thumbnail" -t attr -n "url" -v "`cat "$nomDuFichier" | grep -o -e '"thumbnail": "[^"]*"' | perl -pe 's@.*: "([^"]*)"@\1@g'`" \
        -r "//thumbnail" -v "media:thumbnail" \
		-r "//currentitem" -v "item" \
		"$PodcastName.xml"
done
