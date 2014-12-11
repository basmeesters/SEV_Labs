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

// Example files
public loc f1 = |project://smallsql0.21_src/src/smallsql/database/ExpressionFunctionReturnP1.java|;
public loc f2 = |project://smallsql0.21_src/src/smallsql/database/ExpressionArithmetic.java|;

// Get all the duplications in two files
public duplicationMap FileDuplications(loc p1, loc p2, int t, int tp)
{
	ast1 = createAstFromFile(p1, false);
	ast2 = createAstFromFile(p2, false);
	
	if (tp == 2) {
		ast1 = SerializedAST(ast1);
		ast2 = SerializedAST(ast2);
		
		statements = MethodStatements(ast1, t);
		statements += MethodStatements(ast2, t);
	}
	
	statements = MethodStatements(ast1, t);
	statements += MethodStatements(ast2, t);
	
	duplicationMap h = Filter(Hash(statements));
	return Subclones(h);
}

// Print the found clones to the right format
public void Format(loc p1, loc p2, int t, int tp)
{
	duplicationMap duplications = FileDuplications(p1, p2, t, tp);
	r1 = [];
	r2 = [];	
	int i = 0;
	for (k <- duplications) {
		for (tuple[loc a,list[Statement] b, int c] r <- duplications[k]) {
			if (toLocation(r.a.uri) == p1)
				r1 += <i, r.a.begin.line,r.a.end.line>;
			else 
				r2 += <i, r.a.begin.line,r.a.end.line>;
		}	
		i += 1;
	}
	// File 1
	str p = replaceAll(replaceAll("<p1>", "|", ""), "/", "_");
	loc file = |file:///C:/wamp/www/similyzer/communicator/f1Type1.data|;
	if (tp == 2)
		file = |file:///C:/wamp/www/similyzer/communicator/f1Type2.data|;
	str s = "";
	codeFile1 = generateMarkedCode(p1, r1);
	for (str i <- codeFile1)
		s += "<i>\n";
	writeFile(file, s);
	
	// File 2
	p = replaceAll(replaceAll("<p2>", "|", ""), "/", "_");
	file = |file:///C:/wamp/www/similyzer/communicator/f2Type1.data|;
	if (tp == 2)
		file = |file:///C:/wamp/www/similyzer/communicator/f2Type2.data|;
	s = "";
	list[str] codeFile2 = generateMarkedCode(p2, r2);
	for (str i <- codeFile2)
		s += "<i>\n";
	writeFile(file, s);
}

// Generate a list of strings of original code marked with tags for duplications
public list[str] generateMarkedCode(loc path, list[tuple [int t, int beginLine, int endLine]] clones) {
	list[str] codeLines = readFileLines(path);
	for(clone <- clones) {
		str firstLine = codeLines[clone.beginLine];
		codeLines[clone.beginLine] = "\<highlight-me class=\'highlight-me n<clone.t>\'highlight-me-end\><firstLine>";
		
		str lastLine = codeLines[clone.endLine];
		codeLines[clone.endLine] = "<lastLine>\</highlight-me\>";
	}
	return codeLines;
	
}