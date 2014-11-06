module Volume

import CodeLines;
import FilesHandling;
import lang::java::jdt::m3::Core;

public loc simple = |project://Hello|;
public loc advanced = |project://smallsql0.21_src|;

public map[loc, int] CountUnits(loc project, str ext) 
{
	map[loc, int] dictionary =();
	list[loc] files = getFiles(project, ext);
	for (f <- files) {
		dictionary += (f: linesOfCode(f));
	}
	return dictionary;
}

public int Count(loc project, str ext)
{
	list[loc] files = getFiles(project, ext);
	int count = 0;
	for (f <- files) {
		count += linesOfCode(f);
	}
	return count;
}