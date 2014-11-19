module CodeLines

import List;
import IO;
import String;

public loc file = |project://Hello/src/testPack/Main.java|;

// Give the actual lines of code given a string by removing comments and blank lines
public list[str] CleanCode2(loc path) 
{
	list[str] lines = readFileLines(path);
	return CleanCode2(lines, 0, size(lines) - 1);
}

public list[str] CleanCode2(list[str] lines, int beginLine, int endLine) 
{
	// Bool used for multi-line comments
  	bool comment = true;
  	
  	list[str] code = [];
  	list[str] newLines;
  	
  	// Give only the clean code within the range
  	if (beginLine > 0)
  		newLines = take(endLine - (beginLine -1), (drop(beginLine - 1, lines)));
  		
  	// Give the code without range
	else
		newLines = lines;
  	for (l <- newLines) {
  		line = trim(l);
  		if (size(line) >= 2) {
	  		str sub = substring(line, 0, 2);
	  		if(sub := "//") {
	  			;
			}
			else if(sub:= "/*"){
				comment = false;
			}
			else if (contains(line, "*/")) {
				comment = true;
			}
			else if (comment := true){
				code += line;
			}
		}
		else if (comment := true && size(line) >0) {
			code += line;
		}
  	}
  return code;
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
			case /\"<m: .*>\"/		:	line = replaceAll(line, m, "");
			case /<m: \/\*.*>/  	: 	{line = replaceAll(line, m, ""); noComment = false; }
			case /<m: .*\*\/>/ 		: 	{line = replaceAll(line, m, ""); noComment = true; }
			case /<t:\t>/ 			: 	line = replaceAll(line, t, " ");
			case /\/\/.*/ 			: 	{ line = "";  } //
		}
		if (line != "" && line != "\n" && noComment) {
			code += line;
			//println(line);
		}
	}
	return code;
}