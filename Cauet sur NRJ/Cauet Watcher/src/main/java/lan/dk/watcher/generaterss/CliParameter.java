package lan.dk.watcher.generaterss;

import com.beust.jcommander.Parameter;

public class CliParameter {

	@Parameter(names = "-path", description = "Path to Watch")
	String PathToWatch;
	@Parameter(names = "-rss", description = "Name of the RSS to write in")
	String RssToWrite;
	@Parameter(names = "-serveurUrl", description = "Url to the server")
	String serveurUrl;

	@Parameter(names = { "-log", "-verbose" }, description = "Active le mode verbeux")
	private boolean log = false;

	public String getPathToWatch() {
		return PathToWatch;
	}

	public void setPathToWatch(String pathToWatch) {
		PathToWatch = pathToWatch;
	}

	public String getRssToWrite() {
		return RssToWrite;
	}

	public void setRssToWrite(String rssToWrite) {
		RssToWrite = rssToWrite;
	}

	public String getServeurUrl() {
		return serveurUrl;
	}

	public void setServeurUrl(String serveurUrl) {
		this.serveurUrl = serveurUrl;
	}

	public boolean isLog() {
		return log;
	}

	public void setLog(boolean log) {
		this.log = log;
	}

}
