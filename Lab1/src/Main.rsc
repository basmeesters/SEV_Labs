module Main

import FilesHandling;
import Complexity;
import Volume;
import Set;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc hsqldb = |project://hsqldb-2.3.1|;

// Simple 
public set[Declaration] simpleDecls = createAstsFromEclipseProject(simple,true);
public M3 model = createM3FromEclipseProject(simple);
public Declaration methodAST = getMethodASTEclipse(|java+method:///testPack/Main/main(java.lang.String%5B%5D)|, model=model);
public list[loc] locations = [m@src | /Expression m := methodAST];

// Example extract information (not really needed but to learn Rascal)
public list[loc] classes = [ e | e <- model@containment[|java+package:///testPack|]];
public list[loc] methods = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+method"];
public list[loc] fields = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+field"];
	
// Extract method
public void Extract(loc project, str ext)
{
	// Lines of code per unit
	map[loc, int] volume = CountUnits(project, ext);
	
	//Lines of code total
	int totalVolume = sumMap(volume);
	
	// Cyclomatic complexity per unit
	set[Declaration] dcls = createAstsFromEclipseProject(simple,true);
	map[loc, int] complexity = Complexity(dcls);
	map[loc, int] riskLevel = Risk(complexity);
	
}

public set[Declaration] Decl(loc project) {return createAstsFromEclipseProject(project,true); }