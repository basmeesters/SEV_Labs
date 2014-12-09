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

alias duplicationMap = map[list[Statement], list[list[Statement]]];

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// Get all the subtrees given a node 
public list[tuple[node,int]] Subtrees(node a, int t) = [<n,s> | /node n <- a, s <- [SizeTree(n)], s >= t];
private int SizeTree(node n) = (0|it+1|/node _ <-n);

// Get clones
public map[node,list[node]] GetClones(loc project, int t)= 	Subclones(FilterClones(MethodTrees(AST(project), t)));

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
	// dict = Hash(statements);
	//for (l <- dict)
	//	println("<dict[l]> & <l>");
	return createDuration(time, now());
}

// Runs in less than 2 seconds on smallSQL
public list[Statement] GetStatements(list[Statement] method)
{
	list[Statement] statements = [];
	for (s <- method) {
		statements += s; 
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
		}
	}
	return statements;
}

public list[tuple[loc, list[Statement], int]] Sublists(list[Statement] statements, int t)
{
	lists = [];
	i = 0;
	amount = size(statements);
	for (s <- statements) {
		sub = [];
		c = 0;
		int subsize = 0;
		for (j <- [k|i + t < amount, k <- [i..amount]]) {
			sub += statements[j];
			if (j -1 >= t)
				lists += MakeBlock(sub);
		}
		i += 1;
	}
	return lists;
}

public list[tuple[loc, list[Statement], int]] MakeBlocks(list[Statement] statements, int t)
{
	newDict = [];
	int s = 0;		// Size of the block
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (Statement x <- statements) {
		tempList = [];
		int q = 0;
		while (q + c < boundary) {
			Statement newTup = statements[c + q]; 
			tempList += newTup;
			if(q - c >= t)
				newDict += MakeBlock(tempList); //Hash(m, tempList); // +=?  !!!!!!
			q += 1;
		}
		c += 1;
		s = 0;
	}
	return newDict;
}

public tuple[loc, list[Statement], int] MakeBlock(list[Statement] statements)
{
	int endLine = 0;
	int endColumn = 0;
	newStatements = [];
	// Get location
	Statement first = statements[0];
	loc location = statements[0]@src;
	int startLine = location.begin.line;
	loc last;
	for (Statement b <- statements)
		last = b@src;
	endLine = last.end.line;
	endColumn = last.end.column;
	length = last.offset - location.offset + last.length;
	// Create new tuple
	newLocation = location(location.offset,length,<location.begin.line,location.begin.column>,<endLine,endColumn>);
	return <newLocation, statements, endLine - startLine + 1>;
}

// Create map and hash the subtrees
public map[list[Statement], list[loc]] Hash (list[tuple[loc, list[Statement], int]] statementList)
{
	//newDict = (distr | tuple[loc a, list[Statement] b, int c] s <- statementList);
	dict =  (() | 
		s.b in it ? 
			(it +(s.b : it[s.b] + [s.a])) : 
			(it + (s.b : [s.a]))
			| 
			tuple[loc a, list[Statement] b, int c] s <- statementList);
	println(size(dict));
	return dict;
}

// Filter out only subtrees with multiple instances (clones)
private duplicationMap FilterClones(duplicationMap trees)
{
	dict = ();
	for(list[Statement] a <- trees) {
		s = size(trees[a]);
		if (s > 1) {
			dict += (a: trees[a]);
			//println("<dict[a]>");
			
		}
	}
	return dict;
}

private map[node,list[node]] Subclones(map[node,list[node]] trees)
{
	dict = ();
	for (tree <- trees) {
		switch(tree) {
			case \block(bl)	: 	
			{
				bool clone = false;
				bool clone2 = false;
				node temp;
				for (key <- dict) {
					switch(key) {
						case \block(k) :
						{
							if (bl <= k || /tree := key) {
								clone = true;
							}
							else if(k <= bl || /key := tree) {
								clone2 = true;
								temp = key;
							}
						}
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
		}
	}
	return dict;
}