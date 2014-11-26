module Main

import FilesHandling;
import Volume;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Duplication;
import IO;
import util::FileSystem;
import DateTime;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

public void Extract(loc project, bool log, set[Declaration] dcls)
{
	time = now();

	// All useful lines of code (no comments or blank lines)
	map[loc, list[str]] codeUnits = CodePerFile(project);
	
	if (log) {
		str p = replaceAll(replaceAll(locToStr(project), "|", ""), "/", "_");
		loc file = |project://Lab1/<p>.txt|;
		function = void (str string){appendToFile(file, string);};
		appendToFile(file, "Measure project at: <time>\n\n");
		appendToFile(file, "<createDuration(time, now())>\n-----------------------------------------------------\n\n");
	}
	else 
		Results(totalVolume, riskLevelVolume, riskLevelComplexity, duplicationCounter, print);
}