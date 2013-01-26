#!/bin/bash

text_to_html() {
	text=$1
	text=${text//&/&amp;}
	text=${text// /%20}
	text=${text//#/%23}
#	text=${text//é/&#xe9;}
	echo $text
}

cp /home/###/###/Freebox/* /home/###/Freebox/Enregistrements/ #Copie des images vers le dossiers de la freebox
serveur="http://url/du/dossier/Freebox/sur/le/serveur/http" #Element à modifier pour pointer vers le réel dossiers 

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
cd /home/###/Freebox/Enregistrements/
for chaine in $(ls *.m2ts | cut -d'-' -f1 | sed -e "s@^\([^ ]*\)@\1@g" -e 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq); do 
	#echo Création de $chaine
	chaineHTML=`text_to_html "$chaine"`
	#Pour chaque chaine, créer un flux
	echo '<?xml version="1.0" encoding="UTF-8"?><rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" />' > "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "/rss" -t elem -n "channel" -v "" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel" -t elem -n "title" -v "Freebox - $chaine.xml" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel" -t elem -n "pubdate" -v "`date --rfc-2822`" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel" -t elem -n image -v "" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel/image" -t elem -n url -v "${serveur}/$chaineHTML.png" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel/image" -t elem -n title -v "${nomPodcast}" "Freebox - $chaine.xml"
	xmlstarlet ed -L -s "//channel/image" -t elem -n link -v "${serveur}/" "Freebox - $chaine.xml"

	for emission in $(ls -t | grep -e "$chaine.*.m2ts$"); do 
		emissionHTML=`text_to_html "$emission"`
		titre=`echo ${emission#* - } | cut -d"-" -f1 | sed -e "s@^ *\([^ ]*\)@\1@g" -e 's/^[ \t]*//;s/[ \t]*$//'`
		titreHTML=`text_to_html "$titre"`
		pubdate=`echo $emission | sed -e "s@^.*\([0-9]\{2\}\)-\([0-9]\{2\}\)-\([0-9]\{4\}\) \([0-9]\{2\}\)h\([0-9]\{2\}\).*@\3-\2-\1 \4:\5@g" -e 's/^[ \t]*//;s/[ \t]*$//'`
		description=`xmlstarlet sel -t -v "//channel[title='${chaine//\'/ }']/show[title='${titre//\'/ }']/description" /home/###/Podcast/Freebox/description.xml`
		xmlstarlet ed -L -N media="http://search.yahoo.com/mrss/" -s "//channel" -t elem -n item -v "" -s "//item[text()='']" -t attr -n currentnode -v "yes"  \
			-s "//item[@currentnode='yes']" -t elem -n title -v "$titre" \
			-s "//item[@currentnode='yes']" -t elem -n guid -v "$emission" \
			-s "//item[@currentnode='yes']" -t elem -n link -v "$serveur/$emissionHTML" \
			-s "//item[@currentnode='yes']" -t elem -n enclosure -v "" \
			-s "//item[@currentnode='yes']/enclosure" -t attr -n url -v "$serveur/$emissionHTML" \
			-s "//item[@currentnode='yes']/enclosure" -t attr -n length -v "`stat -c%s $emission`" \
			-s "//item[@currentnode='yes']/enclosure" -t attr -n type -v "video/m2ts" \
			-s "//item[@currentnode='yes']" -t elem -n pubDate -v "`date -d $pubdate --rfc-2822`" \
			-s "//item[@currentnode='yes']" -t elem -n description -v "$description"  \
			-s "//item[@currentnode='yes']" -t elem -n "thumbnail" -v "" \
			-s "//item[@currentnode='yes']/thumbnail" -t attr -n "url" -v "$serveur/$titreHTML.png" \
			-r "//thumbnail" -v "media:thumbnail" \
			-d "//item[@currentnode='yes']/@currentnode" \
			"Freebox - $chaine.xml"
	done
done

for podcastToDelete in $(ls Freebox*.xml | grep -v "`ls *.m2ts | cut -d'-' -f1 | sed -e "s@^\([^ ]*\)@\1@g" -e 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq`"); do
	#echo Suppression des épisodes de $podcastToDelete 
	xmlstarlet ed -L -d "//item" $podcastToDelete
done

IFS=$SAVEIFS
