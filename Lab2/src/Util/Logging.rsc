module Util::Logging

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import util::FileSystem;
import DateTime;
import AST::Tree;
import String;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

public void Write(loc project, bool log, int threshold)
{
	str p = replaceAll(replaceAll("<project>", "|", ""), "/", "_");
	loc file = |project://Lab2/<p>.txt|;
	Write(project, log, file, threshold);
}

public void Write(loc project, bool log, loc file, int threshold)
{
	if (log) 
		Results(project, void (str string){appendToFile(file, string);}, threshold);
	else 
		Results(project, print, threshold);
	
}

// TODO read

public void Results(loc project, void (str string) log, int t)
{
	time = now();
	log("\n-----------------------------------------------------\nMeasure project at: <time>\n\n");
	
	// Actual work:
	int sm =0;
	map[node,list[node]] trees = GetClones(project, t);
	int i =0;
	for(node a <- trees) {
		i += 1;
		top-down-break visit(trees[a]) {
			case Statement b 	: 	
			{
				log("<i> : <b@src>\n");
				sm += (b@src.end.line - b@src.begin.line + 1);
			}
		}
	}
	log("<sm>\n");
	log("\n<createDuration(time, now())>\n-----------------------------------------------------");
}