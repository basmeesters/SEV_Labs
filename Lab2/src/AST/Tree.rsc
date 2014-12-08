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
	map[node,list[node]] dict = ();
	statements = [];
	top-down visit(ast) {
		case a:\constructor(n, p, e, s)	:	statements += MakeBlocks(GetStatements([s]), t); // dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
		case a:\method(r,n, p, e, s) 	:	statements += MakeBlocks(GetStatements([s]), t); // dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
	}
	for (tuple[loc a, list[Statement] b, int c] s <- statements)
		println("<s.a>");
	return createDuration(time, now());
}

public void GetSubs(set[Declaration] ast)
{
	statements = [];
	visit(ast) {
		case a:\constructor(n, p, e, s)	:	{statements += Subtrees(a, 0);println("1 : <Subtrees(a, 0)>"); }// dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
		case a:\method(r,n, p, e, s) 	:	{statements += Subtrees(a, 0);println("1 : <Subtrees(a, 0)>"); }
	}
		for (tuple[S a, int b] s <- statements)
		println("<s.a>");
}

public list[Statement] GetStatements(list[Statement] method)
{
	list[Statement] statements = [];
	for (s <- method) {
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
			default								:	statements += s; 
			
		}
	}
	return statements;
}

public list[tuple[loc,list[Statement], int]] Sublists(list[Statement] statements, int t)
{
	list[tuple[loc,list[Statement], int]] lists = [];
	i = 0;
	amount = size(statements);
	//println(amount);
	for (s <- statements) {
		sub = [];
		c = 0;
		int subsize = 0;
		for (j <- [i..amount]) {
			sub += statements[j];
			tuple[loc a, list[Statement] b, int c] newBlock = MakeBlock(sub);
			if (j - i >= t) {
				lists += newBlock;
			}
		}
		i += 1;
	}
	//println(lists);
	return lists;
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

public list[tuple[loc, list[Statement], int]] MakeBlocks(list[Statement] statements, int t)
{
	newList = [];
	int s = 0;		// Size of the block
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (Statement x <- statements) {
		tempList = [];
		int q = 0;
		while (q + c < boundary) {
			Statement newTup = statements[c + q]; 
			tempList += newTup;
			q += 1;
		}
		if ((q - c) >= t) {
			newList += MakeBlock(tempList);

		}
		c += 1;
		s = 0;
	}
	return newList;
}

// Create map and hash the subtrees
private map[node, list[node]] Hash (map[node, list[node]] dict, list[tuple[node,int]] trees, int t)
{
	for (tuple[node a,int b] l <- trees) {
		switch(l.a) {
			case Statement n : 
			{
				bool temp = false;
				if (n in dict) {
					for (j <- dict[n]) {
						Statement i;
						switch(j) { case Statement b : i = b; }
						if (abs(i@src.begin.line - n@src.begin.line) <= 1) {
							temp = true;
							break;
						}
					}
					if (temp == false && l.b >= t) {
						dict += (n : dict[n] + n);
					}
				}
				else
					dict += (n : [n]);
			}
		}
	}
	return dict;
}

// Filter out only subtrees with multiple instances (clones)
private map[node,list[node]] FilterClones(map[node,list[node]] trees)
{
	dict = ();
	for(node a <- trees) {
		s = size(trees[a]);
			if (s > 1) {
				dict += (a: trees[a]);
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