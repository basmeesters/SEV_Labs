module AST::Tree

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;
import util::Math;
import DateTime;
import Set;
import Relation;

alias duplicationMap = map[list[Statement], rel[loc,list[Statement],int]];

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// Print the results
public int Print(loc project, int t)
{
	statements = MethodStatements(AST(project), t);
	duplicationMap h = Hash(statements);
	//h = Subclones(h);
	totalSize = 0;
	for (list[Statement] s <- h) {
		println(s);
		tuple[loc a,list[Statement] b,int c] first = getOneFrom(h[s]);
		int listSize = size(h[s]);
		cloneSize = first.c * (listSize -1);
		totalSize += cloneSize;
		println("<cloneSize>");
		for (tuple[loc a,list[Statement] b,int c] tup <- h[s]) {
			println(tup.a);
		}
	}
	println(totalSize);
	return totalSize;
}

// Get all subtrees within methods / constructors
public list[list[Statement]] MethodStatements(set[Declaration] ast, int t)
{
	statements = [];
	top-down-break visit(ast) {
		case a:\initializer(s)			:	statements += MakeBlocks(GetStatements([s]), t);
		case a:\constructor(n, p, e, s)	:	statements += MakeBlocks(GetStatements([s]), t); 
		case a:\method(r,n, p, e, s) 	:	statements += MakeBlocks(GetStatements([s]), t);
	}
	return statements;
}

// Get all subtrees within methods / constructors
public list[Statement] MethodStatements2(set[Declaration] ast, int t)
{
	statements = [];
	top-down-break visit(ast) {
		case a:\initializer(s)			:	statements += GetStatements([s]);
		case a:\constructor(n, p, e, s)	:	statements += GetStatements([s]);
		case a:\method(r,n, p, e, s) 	:	statements += GetStatements([s]);
	}
	return statements;
}

// Get all statements in a particular method or block of statements (recursively)
public list[Statement] GetStatements(list[Statement] method)
{
	list[Statement] statements = [];
	for (s <- method) {
		//statements += s; 
		switch(s) {
			case \block(b) 						:	statements += GetStatements(b); 
			case \do(b,_)						: 	statements += GetStatements([b]);
			case \foreach(_,_,b)				:	statements += GetStatements([b]); 
			case \for(_,_,_,b)					:	statements += GetStatements([b]); 
			case \for(_,_,b)					:	statements += GetStatements([b]); 
			case \if(_,b)						:   statements += GetStatements([b]);
    		case \if(_,b, b2)					:   { statements += GetStatements([b]); statements += GetStatements([b2]); }
    		case \label(_,b)					:   statements += GetStatements([b]);  
			case \switch(_,b)					:	statements += GetStatements(b); 
			case \synchronizedStatement(_,b) 	:	statements += GetStatements([b]); 
			case \try(b,e)						:	{statements += GetStatements([b]); statements += GetStatements(e); }
			case \try(b,e,_)					:	{statements += GetStatements([b]); statements += GetStatements(e); } 
			case \catch(_,b)					:	statements += GetStatements([b]);
			case \while(_,b)					:	statements += GetStatements([b]);
			default 							:	statements += s;					
		}
	}
	return statements;
}

// Create sublists of the lists of statements bigger than the threshold t
public list[list[Statement]] MakeBlocks(list[Statement] statements, int t)
{
	newDict = [];
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (Statement x <- statements) {
		tempList = [];
		int q = 0;
		while (q + c < boundary) {
			Statement newTup = statements[c + q]; 
			tempList += newTup;
			if(q - c + 1>= t)
				newDict += [tempList]; 
			q += 1;
		}
		c += 1;
	}
	return newDict;
}

// Create a tuple of location, code and size of the code for a list of statements
public tuple[loc, list[Statement], int] MakeBlock(list[Statement] statements)
{
	int endLine = 0;
	int endColumn = 0;
	newStatements = [];
	Statement first = statements[0];
	loc location = statements[0]@src;
	int startLine = location.begin.line;
	loc last;
	for (Statement b <- statements)
		last = b@src;
	endLine = last.end.line;
	endColumn = last.end.column;
	length = last.offset - location.offset + last.length;
	newLocation = location(location.offset,length,<location.begin.line,location.begin.column>,<endLine,endColumn>);
	return <newLocation, statements, endLine - startLine + 1>;
}

// Hash the statements to a map and filter out all keys with value sizes lower than 1
public duplicationMap Hash(list[list[Statement]] statements)
{
	m = toMap([<s, MakeBlock(s)>| s <- statements]);
	newM = (r : m[r] | r <- m, size(m[r]) > 1);
	return newM;
}

// TODO improve filtering..
private duplicationMap Subclones(duplicationMap trees)
{
	dict = ();
	for (tree <- trees) {
		bool clone = false;
		bool clone2 = false;
		node temp;
		for (key <- dict) {
			if (tree <= key) {
				clone = true;
			}
			else if(key <= tree) {
				clone2 = true;
				temp = key;
			}
		}
		if (clone) ;
		else if(clone2) {
			dict = delete(dict, temp);
			dict += (tree : trees[tree]);
		}
		else
			dict += (tree : trees[tree]);
	}
	return dict;
}