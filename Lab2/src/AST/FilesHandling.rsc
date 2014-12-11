module AST::FilesHandling

import util::FileSystem;
import IO;
import String;

public list[loc] getFiles (loc path, str ext) {
	if(isDirectory(path) == false) {
		return [path];
	}
	list[loc] dirContent = path.ls;
	list[loc] filteredFilesList = [];
	
	for(loc xPath <- dirContent) {
		if(isDirectory(xPath) == true)
			filteredFilesList += getFiles(xPath, ext);
		if (getExt(xPath) == ext)
			filteredFilesList += xPath;
	}
	return filteredFilesList;
}

public str getExt(loc path) {
	str pathString = locToStr(path);
	if (/[.]<fileExt:[A-Za-z0-9]+>[|]$/ := pathString) {
	return fileExt;
	}
	return "";
}

public str locToStr (loc location) {
	return "<location>";
}