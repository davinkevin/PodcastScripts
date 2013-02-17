package lan.dk.watcher.generaterss;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.List;

import name.pachler.nio.file.ClosedWatchServiceException;
import name.pachler.nio.file.FileSystems;
import name.pachler.nio.file.Path;
import name.pachler.nio.file.Paths;
import name.pachler.nio.file.StandardWatchEventKind;
import name.pachler.nio.file.WatchEvent;
import name.pachler.nio.file.WatchKey;
import name.pachler.nio.file.WatchService;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

import com.beust.jcommander.JCommander;

public class WatcherService {

	public static void main(String[] args) {
		WatchService watchService = FileSystems.getDefault().newWatchService();

		// Parse the parameter :
		CliParameter cliParameter = new CliParameter();
		new JCommander(cliParameter, args);

		Path watchedPath = Paths.get(cliParameter.getPathToWatch());

		@SuppressWarnings("unused")
		WatchKey key = null;
		try {
			key = watchedPath.register(watchService, StandardWatchEventKind.ENTRY_CREATE, StandardWatchEventKind.ENTRY_DELETE);
		} catch (UnsupportedOperationException uox) {
			System.err.println("file watching not supported!");
			// handle this error here
		} catch (IOException iox) {
			System.err.println("I/O errors");
			// handle this error here
		}

		// Creation of the Logger :
		Logger logger = Logger.getLogger("Watcher-" + cliParameter.getRssToWrite());
		PatternLayout layout = new PatternLayout("%d %-5p - %m%n");

		try {
			FileAppender fa = new FileAppender(layout, cliParameter.PathToWatch + "/" + "Watcher-" + cliParameter.getRssToWrite() + ".log");
			fa.setEncoding("UTF-8");
			logger.addAppender(fa);
			if (cliParameter.isLog()) {
				ConsoleAppender stdout = new ConsoleAppender(layout);
				stdout.setEncoding("UTF-8");
				logger.addAppender(stdout);
			}
		} catch (IOException e1) {
			e1.printStackTrace();
		}

		logger.info("Lancement du Watcher sur " + cliParameter.getRssToWrite() + " " + Charset.defaultCharset());
		GenerateRSS.WriteRSS(cliParameter.getPathToWatch(), cliParameter.getRssToWrite(), cliParameter.getServeurUrl());
		for (;;) {
			// take() will block until a file has been created/deleted
			WatchKey signalledKey;
			try {
				signalledKey = watchService.take();
			} catch (InterruptedException ix) {
				// we'll ignore being interrupted
				continue;
			} catch (ClosedWatchServiceException cwse) {
				// other thread closed watch service
				System.out.println("watch service closed, terminating.");
				break;
			}

			// get list of events from key
			List<WatchEvent<?>> list = signalledKey.pollEvents();

			// VERY IMPORTANT! call reset() AFTER pollEvents() to allow the
			// key to be reported again by the watch service
			signalledKey.reset();

			// we'll simply print what has happened; real applications
			// will do something more sensible here
			for (@SuppressWarnings("rawtypes")
			WatchEvent e : list) {
				if (e.kind() == StandardWatchEventKind.ENTRY_CREATE) {
					logger.info("Création d'un fichier");
					GenerateRSS.WriteRSS(cliParameter.getPathToWatch(), cliParameter.getRssToWrite(), cliParameter.getServeurUrl());
				} else if (e.kind() == StandardWatchEventKind.ENTRY_DELETE) {
					logger.info("Suppression d'un fichier");
					GenerateRSS.WriteRSS(cliParameter.getPathToWatch(), cliParameter.getRssToWrite(), cliParameter.getServeurUrl());
				} else if (e.kind() == StandardWatchEventKind.OVERFLOW) {
					logger.info("Modification non prise en compte");
				}
			}
		}
	}
}
