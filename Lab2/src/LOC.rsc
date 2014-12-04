module LOC

import FilesHandling;
import String;
import List;
import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import DateTime;

public loc file = |project://Hello/src/testPack/Main.java|;
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

// Get all the lines of code of a project per file
public map[loc, list[str]] CodePerFile(loc project) 
{
	map[loc, list[str]] dictionary =();
	list[loc] files = getFiles(project, "java");
	for (f <- files) {
		dictionary += (f: CleanCode(f));
	}
	return dictionary;
}

// Calculate the total amount of lines of code
public int LinesOfCode(loc project)
{
	codeUnits = CodePerFile(project);
	return LinesOfCode(codeUnits);
}

public int LinesOfCode(map[loc, list[str]] codeUnits)
{
	int total = (0 | it + size(codeUnits[location]) | location <- codeUnits);
	return total;
}

public list[str] CleanCode(loc path)
{
	list[str] lines = readFileLines(path);
	return CleanCode(lines, 0, size(lines) - 1);
}

public list[str] CleanCode(list[str] lines, int beginLine, int endLine) 
{
		// Bool used for multi-line comments
  	bool noComment = true;
  	bool noString = true;
  	
  	list[str] code = [];
  	list[str] newLines;
  	
  	// Give only the clean code within the range
  	if (beginLine > 0)
  		newLines = take(endLine - (beginLine -1), (drop(beginLine - 1, lines)));
  		
  	// Give the code without range
	else
		newLines = lines;
	for (l <- newLines)
	{
		line = trim(l);
		visit(line)
		{
			case /\"<m: .*\/\*>\"/	:	line = replaceAll(line, m, ""); 						// Strings
			case /\"<m: .*\*\/>\"/	:	line = replaceAll(line, m, ""); 	
			case /\"<m: .*\/\/>\"/	:	line = replaceAll(line, m, ""); 	
			case /<m:\/\/.*>/ 		: 	line = replaceAll(line, m, ""); 						// Single line
			case /<m: \/\*.*>/  	: 	{line = replaceAll(line, m, ""); noComment = false;}	// Multi line star
			case /<m: .*\*\/>/ 		: 	{line = replaceAll(line, m, ""); noComment = true; }	// Multi line end	
		}
		//line = replaceAll(line, " ", "");
		if (line != "" && line != "\n" && noComment && line != " ") {
			code += line;
		}
	}
	return code;
}

public map[loc, list[str]] LinesPerUnit(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return LinesPerUnit(dcs);
}

public map[loc, list[str]] LinesPerUnit(set[Declaration] dcs)
{
	// Map of locations of units with their size
	map[loc, list[str]] dict = ();
	
	// Start and end line of each unit
	int startLine;
	int endLine;
	
	for (d <- dcs)
	{
		// For each declaration read the lines ones 
		list[str] lines = readFileLines(d@src);
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: 
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				
				// Clean the code for the particular given range and count the lines afterwards
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : uv); 
			}
			case a:\method(_,_,_,_,Statement s) 	: 
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : uv); 
			}
			case a:\method(_,_,_,_)					:  
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode(lines, startLine, endLine);
				dict += (a@src : uv); 
			} 
		}
	}
	return dict;
}