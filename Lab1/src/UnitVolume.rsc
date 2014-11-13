module UnitVolume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import String;


public map[loc, list[str]] UnitVolume(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return UnitVolume(dcs);
}

public map[loc, list[str]] UnitVolume(set[Declaration] dcs)
{
	map[loc, list[str]] dict = ();
	//println(dcs);
	int count = 0;
	for (d <- dcs)
	{
		list[str] lines = readFileLines(d@src);
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: 
			{
				tuple[list[str] a, int b, list[str] c] uv = UnitVolume2(a@src, lines, count);
				count = uv.b;
				dict += (a@src : uv.a); 
			}
			case a:\method(_,_,_,_,Statement s) 	: 
			{
				tuple[list[str] a, int b, list[str] c] uv = UnitVolume2(a@src, lines, count);
				count = uv.b;
				dict += (a@src : uv.a); 
			}
			case a:\method(_,_,_,_)					: dict += (a@decl : 1); 
		}
	}
	return dict;
}

public tuple[list[str], int, list[str]] UnitVolume2(loc source, list[str] lines, int count)
{
	int openCount = 0;
	bool found = false;
	list[str] newLines = drop(source.begin.line, lines);
	bool comment = true;
  	int c = 1;
  	list[str] code = [];
  	for (l <- newLines) {
  		line = trim(l);
  		openCount += size(findAll("{", line));
  		openCount -= size(findAll("}", line));
  		if (openCount > 0)
  			found = true;
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
				c += 1;
			}
		}
		else if (comment := true && size(line) >0) {
			code += line;
			c += 1;
		}
		if (openCount == 0 && found == true)
			break;
  	}
  	count += c;
  return <code, count, newLines>;
}