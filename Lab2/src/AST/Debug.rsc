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

// small, blocksize 8 :: 1,31,980
public Duration DebugSub(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	statements = [];
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	statements += MakeBlocks(GetStatements([s]), t); 
		case a:\method(r,n, p, e, s) 	:	statements += MakeBlocks(GetStatements([s]), t);
	}
	//for (tuple[loc a, list[Statement] b, int c] s <- statements)
	//	println(s.a);
	//dict = FilterClones(dict);
	return createDuration(time, now());
}

// small, blocksize 8 :: 4:39:177
public Duration Debug(set[Declaration] ast, int t)
{
	time = now();
	duplicationMap dict = ();
	statements = [];
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	statements += Sublists(GetStatements([s]), t); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t)); 
		case a:\method(r,n, p, e, s) 	:	statements += Sublists(GetStatements([s]), t); //dict += Hash(dict, MakeBlocks(GetStatements([s]), t));
	}
	//dict = FilterClones(dict);
	//for (tuple[loc a, list[Statement] b, int c] s <- statements)
	//	println(s.a);
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

