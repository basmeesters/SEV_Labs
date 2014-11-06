module Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import ParseTree;
import String;

// Model of the class
public loc project = |project://Hello|;
public str program = readFile(|project://Hello/src/testPack/Main.java|);

public int linesOfCode(str program) 
{
	int count = 0;

  	bool comment = true;
  	list[str] lines = split("\n", program);
  	for (l <- lines, l != "\r", l != "\t\r") {
  		l2 = trim(l);
  		line = replaceAll(l2, " ", "");
  		if (size(line) >= 2) {
	  		str sub = substring(line, 0, 2);
	  		println(sub);
	  		if(sub := "//") {
	  			;
			}
			else if(sub :="\r")
				;
			else if(sub:= "/*"){
				comment = false;
				//println(<comment>);
			}
			else if (contains(line, "*/")) {
				comment = true;
			}
			else if (comment := true){
				count += 1;
				print(<count>);
				println(line);
			}
		}
		else if (comment := true) {
			count += 1;
			print(<count>);
			println(line);
		}
  	}
  return count;
}
