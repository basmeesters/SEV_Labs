module Volume

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;

// Get the lines of code of a project
public map[loc, list[str]] CodeUnits(loc project, str ext) 
{
	map[loc, list[str]] dictionary =();
	list[loc] files = getFiles(project, ext);
	for (f <- files) {
		dictionary += (f: CleanCode(f));
	}
	return dictionary;
}

// Calculate the total amount of lines of code
public int CountCode(loc project, str ext)
{
	codeUnits = CodeUnits(project, ext);
	return CountCode(codeUnits);
}

public int CountCode(map[loc, list[str]] codeUnits)
{
	int total = (0 | it + size(codeUnits[location]) | location <- codeUnits);
	return total;
}

public int CountCode(map[loc, int] codeUnits)
{
	int total = (0 | it + codeUnits[location] | location <- codeUnits);
	return total;
}

// Get the amount of lines of code per unit
public map[loc,int] CountUnits(loc project, str ext)
{
	codeUnits = CodeUnits(project, ext);
	return CountUnits(codeUnits);
}

public map[loc,int] CountUnits(map[loc, list[str]] codeUnits)
{
	map[loc, int] m = ();
	for (c <- codeUnits)
	{
		m += (c: size(codeUnits[c]));
	}
	return m;
}