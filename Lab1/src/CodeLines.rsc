module CodeLines

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import ParseTree;
import String;

// Give the actual lines of code given a string by removing comments and blank lines
public list[str] CleanCode(loc path) 
{
	list[str] lines = readFileLines(path);
	// Bool used for multi-line comments
  	bool comment = true;
  	
  	list[str] code = [];
  	for (l <- lines) {
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