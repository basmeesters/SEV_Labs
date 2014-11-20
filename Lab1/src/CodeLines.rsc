module CodeLines

import List;
import IO;
import String;

public loc file = |project://Hello/src/testPack/Main.java|;

public list[str] CleanCode(loc path)
{
	list[str] lines = readFileLines(path);
	return CleanCode(lines, 0, size(lines) - 1);
}

// Used for debugging only
public list[str] CleanCode(list[str] lines)
{
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
			case /.*\"<m: .*>\"/	:	
			{
				line = replaceAll(replaceAll(line, "/*", ""), "*/"); noString = false;
			}			
			case /<m:\/\/.*>/ 		: 	line = replaceAll(line, m, "");  							// Single line
			case /<m: \/\*.*>/  	: 	{line = replaceAll(line, m, ""); noComment = false;}
			case /<m: .*\*\/>/ 		: 	{line = replaceAll(line, m, ""); noComment = true; }		// Multi line end	
			case /<m:\t>/ 			: 	line = replaceAll(line, m, " ");							// Tab
		}
		if (line != "" && line != "\n" && noComment && line != " ") {
			code += line;
			//println(line);
		}
	}
	return code;
}