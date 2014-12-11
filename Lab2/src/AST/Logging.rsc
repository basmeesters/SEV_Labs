module AST::Logging

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import util::FileSystem;
import DateTime;
import AST::Tree;
import AST::Serializing;
import String;
import Set;
import List;
import AST::FilesHandling;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

public void GenerateLocations(loc project)
{
	list[loc] files = getFiles(project, "java");
	loc locFile = |project://Lab2/locations.data|; // |file:///C:/wamp/www/similyzer/communicator/locations.data|;
	writeFile(locFile, "");
	for (f <- files)
		appendToFile(locFile, "<f.uri>\n");
}

public void Duplication(loc project, int threshold, int tp)
{
	str p = replaceAll(replaceAll("<project>", "|", ""), "/", "_");
	loc file = |project://Lab2/data_1.data|; //|file:///C:/wamp/www/similyzer/communicator/resultsType1.data|;
	if(tp == 2)
		file = |project://Lab2/data_2.data|;// |file:///C:/wamp/www/similyzer/communicator/resultsType2.data|;
	writeFile(file, "");
	VisualFormat(project, threshold, tp, void (str string){appendToFile(file, string);});
}

public void Print(loc project, int t, int tp, bool log)
{
	str p = replaceAll(replaceAll("<project>", "|", ""), "/", "_");
	loc file = |project://Lab2/data_<p>.data|;
	if (log)
		PrintDetail(project, t,  tp, void (str string){appendToFile(file, string);});
	else 
		PrintDetail(project, t, tp, print);
}

// Print the results
private void PrintDetail(loc project, int t, int tp, void (str string) log)
{
	time = now();
	log("Clone detection for project <project>\n");
	ast = AST(project);
	if (tp == 2) 
		ast = SerializedAST(ast);
	statements = MethodStatements(ast, t);
	duplicationMap h = Filter(Hash(statements));
	h = Subclones(h);
	Report(h, project, log);	
	totalSize = 0;
	int i = 1;
	for (list[Statement] s <- h) {
		log("Clone class # <i>\n");
		tuple[loc a,list[Statement] b,int c] first = getOneFrom(h[s]);
		int listSize = size(h[s]);
		cloneSize = first.c * (listSize -1);
		totalSize += cloneSize;
		for (tuple[loc a,list[Statement] b,int c] tup <- h[s]) {
			log("<tup.a>\n");
		}
		log("Total class duplication size: <cloneSize>\n\n");
		i += 1;
	}
	log("Total size: <totalSize>\n");
	log("<createDuration(time, now())>\n");
}

public void VisualFormat(loc project, int threshold, int tp, void (str string) log)
{
	ast = AST(project);
	if (tp == 2)
		ast = SerializedAST(ast);
	duplicationMap h = Subclones(Filter(Hash(MethodStatements(ast, threshold))));
	VisualFormat(h, tp, log);
}

public void VisualFormat(duplicationMap duplications, int tp, void (str string) log)
{
	relation = [];
	for (k <- duplications) {
		lrel[loc,list[Statement],int] positions = toList(duplications[k]);
		relation += ListPairs(positions);
	}
	str s = "";
	for (tuple[tuple[loc a,list[Statement] b,int c] l1, tuple[loc a,list[Statement] b,int c] l2] r <- relation)
		s += "<r.l1.a.uri>,<r.l2.a.uri>,<r.l1.c>,<r.l1.a.begin.line>,<r.l1.a.end.line>,<r.l2.a.begin.line>,<r.l2.a.end.line>\n";
	log(s);
}

public list[tuple[&T, &T]] ListPairs(list[&T] tlist) {
	int listSize = size(tlist);
	if(listSize <= 1)
		return [];
	list[tuple[&T, &T]] pairs = [];
	for(i <- [0..listSize]) {
		for(n <- [i..listSize]) {
			if(i != n)
				pairs += <tlist[i], tlist[n]>;
		}
	}
	return pairs;
}

public void Report(loc project, int t, int tp, void (str string) log)
{
	ast = AST(project);
	if (tp == 2) 
		ast = SerializedAST(ast);
	statements = MethodStatements(ast, t);
	duplicationMap h = Filter(Hash(statements));
	h = Subclones(h);
	Report(h, project, log);	
}

public void Report(duplicationMap h, loc name, void (str string) log)
{
	log("The clone report of <name>:\n");
	
	totalSize = 0;
	int i = 1;
	int cloneClass = 0;
	int clone = 0;
	for (list[Statement] s <- h) {
		tuple[loc a,list[Statement] b,int c] first = getOneFrom(h[s]);
		int listSize = size(h[s]);
		cloneSize = first.c * (listSize -1);
		if (cloneSize > cloneClass)
			cloneClass = cloneSize;
		if (first.c > clone)
			clone = first.c;
		totalSize += cloneSize;
		i += 1;
	}
	
	log("Amount of clone classes <i>\n");
	log("The biggest clone class has : <cloneClass> lines of code duplicated\n");
	log("The biggest clone has: <clone> lines of code duplicated\n"); 
	log("The total amount of cloned code is: <totalSize> lines of code\n\n");
}
