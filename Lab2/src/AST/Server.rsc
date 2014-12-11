module AST::Server
import IO;
import AST::FilesHandling;
import DateTime;
import List;
import String;
import AST::Logging;
import AST::FileDetails;

loc configReq = |file:///C:/wamp/www/similyzer/communicator/requests.data|;
loc configRes = |file:///C:/wamp/www/similyzer/communicator/responses.data|;

public bool startServer() {
	bool read = true;
	// reset data
	clearConfig();
	while(read) {
		//println("NOP;");
		if(exists(configReq) == false) {
			delay(1);
			continue;
		}
		list[str] requests = readFileLines(configReq);
		int lineNumber = 0;
		for(request <- requests) {
			println("Request: <request>");
			switch(request) {
				case /stop/: read = stopServer();
				case /restart/: read = restartServer();
				case /testReq/: println("test");
				case /testRes/: respond("test", "Server is okay!");
				case /analyze.*/: analyze(request);
				case /comparePair.*/: comparePair(request);
				default: respond("error", "Unknown request: <request>");
			}
			lineNumber += 1;
		}
		// clean requests that have been proceed.
		requests = readFileLines(configReq); // get updated file in case of updates
		//str newContent = requests;
		int lastLine = size(requests)-1;
		if(lastLine < 0) {
			delay(1);
			continue;
		}
		if(lastLine == 0)
			writeFile(configReq, "");
		else
			writeFile(configReq, requests[lineNumber-1..lastLine]);
		delay(1);
	}
	return read;
}

public bool clearConfig() {
	writeFile(configReq, "");
	writeFile(configRes, "");
	return true;
}

public bool stopServer() {
	respond("stop", "Server was stopped!");
	return false;
}

public bool restartServer() {
	respond("restart", "Server was restarted!");
	delay(2);
	return startServer();
}

public bool respond(str command, str response) {
	if(exists(configReq) == false)
		writeFile(configRes, "");
	appendToFile(configRes, "\n<command>:<response>");
	println("response: <response>");
	return true;
}

public bool comparePair(request) {
	if (/[:]<file1:.*>[:][:]<file2:.*>[:][:]<clonesType:.*>$/ := request) {
		clearConfig();
		respond("comparing", "Comparing Files..");
		Format(toLocation(file1), toLocation(file2), 5, toInt(clonesType));
		respond("comparingDone", "Files compared!");
		return true;
	}
	respond("error", "Request is invalid! (<request>)");
	return false;
}

public bool analyze(str request) {
	if (/[:]<path:.*>$/ := request) {
		clearConfig();
		loc location = toLocation(path);
		respond("analyzing", "Analyzing.. \<i\><location>\</i\>");
		GenerateLocations(location);
		Duplication(location, 5, 1);
		Duplication(location, 5, 2);
		respond("analyzingDone", "Analyzed! \<i\><location>\</i\>");
		return true;
	}
	respond("error", "Location is invalid! (<request>)");
	return false;
}

public bool delay(int delay) {
	datetime varDt = now();
	datetime conDt = now();
	Duration diff = varDt - conDt;
	while(diff[5] <= 1) {
		varDt = now();
		diff = varDt - conDt;
	}
	return true;
}