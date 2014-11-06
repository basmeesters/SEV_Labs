module CodeLines

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import ParseTree;
import String;

// Project location and string created 
public loc project = |project://Hello|;
public str program = readFile(|project://Hello/src/testPack/Main.java|);

// Calculate the lines of code given a string
public int linesOfCode(loc path) 
{
	str program = readFile(path);
	// Current count
	int count = 0;
	
	// Check if we are in /* */ comment lines
  	bool comment = true;
  	
  	// Split lines and go through each line
	str string = cleanString(program);
  	list[str] lines = split("\n", string);
  	for (l <- lines) {
  		l2 = trim(l);
  		
  		// Remove whitespace to check if the first real characters are comment characters
  		line = replaceAll(l2, " ", "");
  		if (size(line) >= 2) {
	  		str sub = substring(line, 0, 2);
	  		//println(sub);
	  		if(sub := "//") {
	  			;
			}
			else if(sub :="\r")
				;
			else if(sub:= "/*"){
				comment = false;
			}
			else if (contains(line, "*/")) {
				comment = true;
			}
			else if (comment := true){
				count += 1;
				//print(<count>);
				//println(line);
			}
		}
		else if (comment := true) {
			count += 1;
			//print(<count>);
			//println(line);
		}
  	}
  return count;
}

public str cleanString(str s)
{
	str replaceR = replaceAll(s, "\r\n", "\n");
  	str replaceR2 = replaceAll(replaceR, "\n\r", "\n");
  	str removeR = replaceAll(replaceR2, "\r", "\n");
  	str removeTab = replaceAll(removeR, "\t", "");
  	
  	return removeTab;
}

public int check(str string) 
{ 
	int count = 0;
	visit(string)
	{
		//case /^\r\n/ : count +1;
		//case /^\n\r/ : count +1;
		//case /^\r/ : count +=1;
		//case /^\n/ : count +=1;
		//case /^.*<guy:\r\n|\n\r|\r|\n>.*/ : count +=1;
		case /^\n\r/ : count +=1;
		//case /^\s/ : count +=1;
		//case /^\t/ : count +=1;
	}
	return count;
}