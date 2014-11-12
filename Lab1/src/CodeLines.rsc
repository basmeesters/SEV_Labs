module CodeLines

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import ParseTree;
import String;

// Calculate the lines of code given a string
public list[str] LinesOfCode(loc path) 
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

// Not being used at all now
public str check(str string) 
{ 
	int count = 0;
	str newString = "";
	result = "";
	while (/^<before:[^\r\n]><after:.*$>/ := string) { 
    	result = result +  + "\n";
    	string = after;
    }
	return result;
		//visit(string)
	//{
	//	//case /^\r\n/ : count +1;
	//	//case /^\n\r/ : count +1;
	//	//case /^\r/ : count +=1;
	//	//case /^\n/ : count +=1;
	//	//case /^.*<guy:\r\n|\n\r|\r|\n>.*/ : println(guy);
	//	 case /^<before:^\n\r|^\^r\n|^\r|><white:\n\r|\r\n|\r|>/ : {newString + before;}
	//	// case /^\n\r/ : count +=1;
	//	//case /^\s/ : count +=1;
	//	//case /^\t/ : count +=1;
	//}
}

public int countComments(loc file){
list[str] lines = readFileLines(file);
  n = 0;
  for(s <- lines)
    if(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/)/ := s)   
      n +=1;
  return n;
}