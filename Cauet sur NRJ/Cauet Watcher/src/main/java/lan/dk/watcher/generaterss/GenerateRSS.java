package lan.dk.watcher.generaterss;

import java.io.File;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;

public class GenerateRSS {

	private static FilenameFilter filter = new FilenameFilter() {
		public boolean accept(File directory, String fileName) {
			return fileName.endsWith(".mp3");
		}
	};

	private static Pattern p = Pattern.compile("Cauet sur NRJ - ([^ ]*) - (.*).mp3");

	public static void WriteRSS(String path, String filename, String serveurUrl) {

		try {

			File directory = new File(path);
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
			SimpleDateFormat toRFC = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);
			Namespace itunesNS = Namespace.getNamespace("itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd");
			Element rss = new Element("rss");
			Document doc = new Document(rss);
			rss.addNamespaceDeclaration(itunesNS);

			Element channel = new Element("channel");
			channel.addContent(new Element("title").setText("C'Cauet sur NRJ"));
			channel.addContent(new Element("link").setText(serveurUrl + "/Cauet/C Cauet sur NRJ.xml".replace(" ", "%20")));
			channel.addContent(new Element("language").setText("fr-fr"));
			channel.addContent(new Element("copyright").setText("Davin Kevin Library"));
			channel.addContent(new Element("subtitle", itunesNS).setText("Cauet et toute son équipe animent la libre antenne de NRJ tous les soirs de la semaine et ils maltraitent Jeff !"));
			channel.addContent(new Element("author", itunesNS).setText("Kevin"));
			channel.addContent(new Element("summary", itunesNS).setText("Cauet et toute son équipe animent la libre antenne de NRJ tous les soirs de la semaine et ils maltraitent Jeff !"));
			channel.addContent(new Element("description").setText("Cauet et toute son équipe animent la libre antenne de NRJ tous les soirs de la semaine et ils maltraitent Jeff !"));
			channel.addContent(new Element("image", itunesNS).setAttribute("href", serveurUrl + "/Cauet/folder.png"));
			channel.addContent(new Element("category", itunesNS).setAttribute("text", "humour"));
			channel.addContent(new Element("pubDate").setText(toRFC.format(new Date())));

			Matcher m;
			String[] listOfFilesName = directory.list(filter);
			Arrays.sort(listOfFilesName, Collections.reverseOrder());
			for (String file : listOfFilesName) {
				m = p.matcher(file);

				if (m.find()) {
					String date = m.group(1) + " 20:45";
					String titre = m.group(2);
					File currentFile = new File(path + File.separator + file);

					Element item = new Element("item");
					item.addContent(new Element("title").setText(titre));
					item.addContent(new Element("author", itunesNS).setText("Cauet"));
					item.addContent(new Element("subtitle", itunesNS).setText("Cauet et toute son équipe animent la libre antenne de NRJ tous les soirs de la semaine et ils maltraitent Jeff !"));
					item.addContent(new Element("subtitle", itunesNS).setText("Cauet et toute son équipe animent la libre antenne de NRJ tous les soirs de la semaine et ils maltraitent Jeff !"));
					item.addContent(new Element("image", itunesNS).setAttribute("href", serveurUrl + "/Cauet/folder.png"));
					item.addContent(new Element("enclosure").setAttribute("length", String.valueOf(currentFile.length())).setAttribute("type", "audio/mpeg")
							.setAttribute("url", serveurUrl + "/Cauet/" + file.replace(" ", "%20")));
					item.addContent(new Element("guid").setText(serveurUrl + "/Cauet/" + file.replace(" ", "%20")));

					try {
						Date d = sdf.parse(date);
						item.addContent(new Element("pubDate").setText(toRFC.format(d)));
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					channel.addContent(item);

				}

			}

			rss.addContent(channel);

			// new XMLOutputter().output(doc, System.out);
			XMLOutputter xmlOutput = new XMLOutputter();

			// display nice nice
			xmlOutput.setFormat(Format.getPrettyFormat());
			FileWriter fw = new FileWriter(path + "/" + filename);
			xmlOutput.output(doc, fw);
			fw.close();
		} catch (IOException io) {
			System.out.println(io.getMessage());
		}
	}
}
