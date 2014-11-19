module Volume

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

// Get all the lines of code of a project per file
public map[loc, list[str]] CodePerFile(loc project) 
{
	map[loc, list[str]] dictionary =();
	list[loc] files = getFiles(project, "java");
	for (f <- files) {
		dictionary += (f: CleanCode2(f));
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

// Get the amount of lines of code per unit (method)
public map[loc, int] LinesPerUnit(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return LinesPerUnit(dcs);
}

public map[loc, int] LinesPerUnit(set[Declaration] dcs)
{
	// Map of locations of units with their size
	map[loc, int] dict = ();
	
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
				list[str] uv = CleanCode2(lines, startLine, endLine);
				dict += (a@src : size(uv)); 
			}
			case a:\method(_,_,_,_,Statement s) 	: 
			{
				startLine = a@src.begin.line;
				endLine = a@src.end.line;
				list[str] uv = CleanCode2(lines, startLine, endLine);
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