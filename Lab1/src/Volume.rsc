module Volume

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

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

public map[loc, int] CountUnits(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return CountUnits(dcs);
}


public map[loc, int] CountUnits(set[Declaration] dcs)
{
	map[loc, int] dict = ();
	int startLine;
	int endLine;
	for (d <- dcs)
	{
		list[str] lines = readFileLines(d@src);
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: 
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : size(uv)); 
			}
			case a:\method(_,_,_,_,Statement s) 	: 
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : size(uv)); 
			}
			case a:\method(_,_,_,_)					:  
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : size(uv)); 
			} 
		}
	}
	return dict;
}