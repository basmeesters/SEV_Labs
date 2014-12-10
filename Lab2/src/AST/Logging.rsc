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

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

public void Duplication(loc project, int threshold)
{
	str p = replaceAll(replaceAll("<project>", "|", ""), "/", "_");
	loc file = |project://Lab2/<p>.data|;
	VisualFormat(project, threshold,  void (str string){appendToFile(file, string);});
}

public void VisualFormat(loc project, int threshold, void (str string) log)
{
	duplicationMap h = Subclones(Hash(MethodStatements(AST(project), threshold)));
	VisualFormat(h, log);
}

public void VisualFormat(duplicationMap duplications, void (str string) log)
{
	relation = [];
	for (k <- duplications) {
		lrel[loc,list[Statement],int] positions = toList(duplications[k]);
		relation += listPairs(positions);
	}
	for (tuple[tuple[loc a,list[Statement] b,int c] l1, tuple[loc a,list[Statement] b,int c] l2] r <- relation)
		log("<r.l1.a.uri>, <r.l2.a.uri>, <r.l1.c>, <r.l1.a.begin.line>, <r.l1.a.end.line>, <r.l2.a.begin.line>, <r.l2.a.end.line>\n");
}

public list[tuple[&T, &T]] listPairs(list[&T] tlist) {
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
