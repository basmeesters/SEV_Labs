module AST::Testing

import AST::Tree;
import AST::Serializing;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;
import DateTime;
import Set;
import Relation;
import util::Math;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

// Test MethodStatements


// Test GetStatements
test bool testStatements()
{
	println("Test GetStatements");
	ast = AST(simple);
	statements = [];
	top-down-break visit(ast) {
		case a:\initializer(s)			:	statements += GetStatements([s]);
		case a:\constructor(n, p, e, s)	:	statements += GetStatements([s]);
		case a:\method(r,n, p, e, s) 	:	statements += GetStatements([s]);
	}
	
	s1 = size(statements);
	s2 = AllStatements(simple);
	println("size 1: <s1> & size 2: <s2>");
	int b = abs(s1 - s2);
	return b <= s1 / 20;
}

private int AllStatements(loc project)
{
	ast = AST(project);
	s = 0;
	 visit(ast) {
	 	case \block(_)				:   ;
		case Statement _			:	s += 1;
	}
	return s;
}

// Test MakeBlocks
test bool testBlocks()
{
	println("Test MakeBlocks");
	block1 = generateStatements(simple);
	int thres = 4;
	blocks1 = MakeBlocks(block1, thres);
	for (b <- blocks1) {
		if (size(b) < thres) {
			println("smaller than <thres>: <b>");
			return false;
		}
	}
	println("No block was smaller than given");
	return true;
}

private list[Statement] generateStatements(loc project)
{
	ast = AST(project);
	statements = [];
	top-down-break visit(ast) {
		case a:\initializer(s)			:	statements += GetStatements([s]);
		case a:\constructor(n, p, e, s)	:	statements += GetStatements([s]); 
		case a:\method(r,n, p, e, s) 	: 	statements += GetStatements([s]); 
	}	
	return statements;
}

// Test MakeBlock
test bool testBlock()
{
	ast = AST(simple);
	statements = MethodStatements(ast, 5);
	statementList = getOneFrom(statements);
	tuple[loc a, list[Statement] b, int c] m = MakeBlock(statementList);
	bool b = true;
	for (s <- statementList) {
		if (s@src.begin.line < m.a.begin.line) {
			println(s@src.begin.line);
			println(s@src.end.line);
			println(m.a.begin.line);
			println(m.a.end.line);
			b = false;
			break;
		}	
	}
	return b;
}

// Test Hash
test bool testHash()
{
	ast = AST(simple);
	statements = MethodStatements(ast, 5);
	h = Hash(statements);
	for (s <- statements)
		if (!(s in h)) {
			println("<s> not in the hashmap");
			return false;
		}
	return true;
}

// Test Subclones
test bool testClones()
{
	duplicationMap h = Subclones(Filter(Hash(MethodStatements(AST(simple), 5))));
	hh = Subclones(h);
	return h == hh;
}
