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

alias duplicationMap = map[list[Statement], list[list[Statement]]];

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// Get all subtrees within methods / constructors
public Duration MethodTrees(set[Declaration] ast, int t)
{
	time = now();
	statements = [];
	top-down-break visit(ast) {
		case a:\constructor(n, p, e, s)	:	statements += MakeBlocks(GetStatements([s]), t); 
		case a:\method(r,n, p, e, s) 	:	statements += MakeBlocks(GetStatements([s]), t);
	}
	//dict = FilterClones(dict);
	map[list[Statement], rel[loc,list[Statement],int]] dict = Hash2(statements);
	dict = Subclones(dict);
	for (s <- dict) {
		l = dict[s];
		println("<s>");
		for (tuple[loc a,list[Statement] b,int c] i <- l)
			println(i.a);
	}
	//println(size(dict));
	return createDuration(time, now());
}

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

// Create map and hash the subtrees
public map[list[Statement], list[list[Statement]]] Hash (list[list[Statement]] statementList)
{
	//newDict = (distr | tuple[loc a, list[Statement] b, int c] s <- statementList);
	dict = (s : [s] |s <- statementList);
	//map[list[Statement], list[list[Statement]]] dict =  (() | 
	//	s in it ? 
	//		(it +(s : it[s] + [s])) : 
	//		(it + (s : [s]))
	//		| 
	//		list[Statement] s <- statementList);
			
	// Filter out unique instances
	newDict = (s : dict[s] |s <- dict, size(dict[s]) > 1);
	return newDict;
}

public map[list[Statement], rel[loc,list[Statement],int]] Hash2(list[list[Statement]] statements)
{
	m = toMap([<s, MakeBlock(s)>| s <- statements]);
	newM = (r : m[r] | r <- m, size(m[r]) > 1);
	//newmM = (s : | r <- m, size(m
	return newM;
}

private map[list[Statement], rel[loc,list[Statement],int]] Subclones(map[list[Statement], rel[loc,list[Statement],int]] trees)
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