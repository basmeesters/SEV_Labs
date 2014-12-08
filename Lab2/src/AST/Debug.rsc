module AST::Debug

import AST::Tree;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;
import util::Math;
import DateTime;

// Get all subtrees within methods / constructors
public Duration DebugStatements(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	GetStatements([s]); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t)); 
		case a:\method(r,n, p, e, s) 	:	GetStatements([s]); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t));
	}
	//dict = FilterClones(dict);
	return createDuration(time, now());
}

public Duration DebugSub(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	MakeBlocks(dict, GetStatements([s]), t); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t)); 
		case a:\method(r,n, p, e, s) 	:	MakeBlocks(dict, GetStatements([s]), t); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t));
	}
	//dict = FilterClones(dict);
	return createDuration(time, now());
}

public Duration DebugHash(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += Hash(dict, MakeBlocks(GetStatements([s]), t)); 
		case a:\method(r,n, p, e, s) 	:	dict += Hash(dict, MakeBlocks(GetStatements([s]), t));
	}
	//dict = FilterClones(dict);
	return createDuration(time, now());
}

public Duration DebugFilter(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += Hash(dict, MakeBlocks(GetStatements([s]), t)); 
		case a:\method(r,n, p, e, s) 	:	dict += Hash(dict, MakeBlocks(GetStatements([s]), t));
	}
	dict = FilterClones(dict);
	return createDuration(time, now());
}

