module UnitVolume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import String;

public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;


public map[loc, int] UnitVolume(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return UnitVolume(dcs);
}


public map[loc, int] UnitVolume(set[Declaration] dcs)
{
	// /^.["].*[^\\].["]$/
	map[loc, int] dict = ();
	//println(dcs);
	for (d <- dcs)
	{
		list[str] lines = readFileLines(d@src);
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: 
			{
				tuple[list[str] a, list[str] c] uv = UnitVolume2(a@src, lines);
				dict += (a@src : size(uv.a)); 
			}
			case a:\method(_,_,_,_,Statement s) 	: 
			{
				tuple[list[str] a, list[str] c] uv = UnitVolume2(a@src, lines);
				dict += (a@src : size(uv.a)); 
			}
			case a:\method(_,_,_,_)					:  
			{
				tuple[list[str] a, list[str] c] uv = UnitVolume2(a@src, lines);
				dict += (a@src : size(uv.a)); 
			} 
		}
	}
	return dict;
}

public tuple[list[str], list[str]] UnitVolume2(loc source, list[str] lines)
{
	int openCount = 0;
	bool found = false;
	list[str] newLines = drop(source.begin.line -1, lines);
	bool comment = true;
  	list[str] code = [];
  	for (l <- newLines) {
  		line = trim(l);
  		openCount += size(findAll(line, "{"));
  		if (openCount > 0)
  			found = true;
  		openCount -= size(findAll(line, "}"));
  		//println("source:<source> count:<openCount>");
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
		if (openCount == 0 && found == true)
			break;
  	}
  return <code, newLines>;
}