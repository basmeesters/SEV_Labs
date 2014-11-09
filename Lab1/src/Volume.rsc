module Volume

import CodeLines;
import FilesHandling;
import lang::java::jdt::m3::Core;

public map[loc, int] CountUnits(loc project, str ext) 
{
	map[loc, int] dictionary =();
	list[loc] files = getFiles(project, ext);
	for (f <- files) {
		dictionary += (f: linesOfCode(f));
	}
	return dictionary;
}