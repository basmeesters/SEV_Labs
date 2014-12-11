module AST::FileDetails

import AST::Tree;
import AST::Logging;

import AST::Serializing;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Map;
import Set;
import String;
import util::FileSystem;

public loc f1 = |project://smallsql0.21_src/src/smallsql/database/ExpressionFunctionReturnP1.java|;
public loc f2 = |project://smallsql0.21_src/src/smallsql/database/ExpressionArithmetic.java|;

public duplicationMap FileDuplications(loc p1, loc p2, int t)
{
	ast1 = createAstFromFile(p1, false);
	ast2 = createAstFromFile(p2, false);
	
	statements = MethodStatements({ast1}, t);
	statements += MethodStatements({ast2}, t);
	
	duplicationMap h = Filter(Hash(statements));
	return Subclones(h);
}

public void Format(loc p1, loc p2, int t)
{
	duplicationMap duplications = FileDuplications(p1, p2, t);
	r1 = [];
	r2 = [];	
	for (k <- duplications) {
		for (tuple[loc a,list[Statement] b, int c] r <- duplications[k]) {
			if (toLocation(r.a.uri) == p1)
				r1 += <r.a.begin.line,r.a.end.line>;
			else 
				r2 += <r.a.begin.line,r.a.end.line>;
		}	
	}
	codeFile1 = generateMarkedCode(p1, r1);
	str p = replaceAll(replaceAll("<p1>", "|", ""), "/", "_");
	loc file = |project://Lab2/1.data|;
	str s = "";
	for (i <- codeFile1)
		s += "<i>\n";
	writeFile(file, s);
	p = replaceAll(replaceAll("<p2>", "|", ""), "/", "_");
	file = |project://Lab2/2.data|;
	s = "";
	codeFile2 = generateMarkedCode(p2, r2);
	for (i <- codeFile1)
		s += "<i>\n";
	writeFile(file, s);
}

public list[str] generateMarkedCode(loc path, list[tuple [int beginLine, int endLine]] clones) {
	list[str] codeLines = readFileLines(path);
	for(clone <- clones) {
		str firstLine = codeLines[clone.beginLine];
		//firstLine = insertAt(firstLine, 0, "\<b\>");
		//println(firstLine);
		codeLines[clone.beginLine] = "\<highlight-me\><firstLine>";
		
		str lastLine = codeLines[clone.endLine];
		//lastLine = insertAt(firstLine, size(lastLine), "\</b\>");
		codeLines[clone.endLine] = "<lastLine>\</highlight-me\>";
	}
	return codeLines;
	
}