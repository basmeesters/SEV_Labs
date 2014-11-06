module Volume

import CodeLines;
import FilesHandling;
import lang::java::jdt::m3::Core;

public loc p = |project://Hello|;

public map[loc, int] Count(loc project, str ext) 
{
	map[loc, int] dictionary =();
	list[loc] files = getFiles(project, ext);
	for (f <- files) {
		dictionary += (f: linesOfCode(f));
	}
	return dictionary;
}