module AST::Serializing

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;
import util::Math;

// The project locations
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// One declaration for each file
// https://github.com/cwi-swat/rascal/blob/master/src/org/rascalmpl/library/lang/java/m3/AST.rsc
public set[Declaration] SerializedAST(loc project) = SerializedAST(AST(project));

// Serialize the AST by replacing variable and method names
public set[Declaration] SerializedAST(set[Declaration] ast) 
{
	return visit (ast) 
	{
		case \simpleName(name) 					=> \simpleName("var") 
		case \constructor(name, p, e, s)		=> \constructor("constructor",p,e,s) 
		case \method(r,name, p, e, s) 			=> \method(r,"function", p, e, s) 
		case \method(t,name, p, e)  			=> \method(t,"function", p, e)
		case \parameter(t, name, e)				=> \parameter(t, "x", e)	
		case \variable(name, e)					=> \variable("var", e)	
    	case \variable(name, e, i)				=> \variable("var", e, i)	
    	case \type(t)							=> \type(\boolean())
	}
}

// Filter out subclones form bigger clones
private map[node,list[node]] Subclones(map[node,list[node]] trees)
{
	dict = ();
	for (i <- trees) {
		bool iClone = false;
		bool jClone = false;
		node temp;
		for (j <- dict) {
			if ( /i := j) {
				iClone = true;
				break;
			}
			else if (/j := i) {
				jClone = true;
				temp = j;
				break;
			}
		}	
		if (jClone) {
			dict = delete(dict, temp);
			dict += (i : trees[i]);
		}
		else if (iClone) 
			; // Do nothing
		else
			dict += (i : trees[i]);
	}
	return dict;
}

public map[node,list[node]] Subclones2(map[node,list[node]] trees)
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

// Get all the subtrees given a node 
public list[tuple[node,int]] Subtrees(node a, int t) = [<n,s> | /node n <- a, s <- [SizeTree(n)], s >= t];
private int SizeTree(node n) = (0|it+1|/node _ <-n);

// Get all subtrees within methods / constructors
private map[node,list[node]] MethodTrees(set[Declaration] ast, int t)
{
	map[node,list[node]] dict = ();
	top-down visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += hash(dict, GroupTrees(Subtrees(a,0), t)); // hash(dict, Subtrees(a,t)); 
		case a:\method(r,n, p, e, s) 	:	dict += hash(dict, GroupTrees(Subtrees(a,0), t)); // hash(dict, Subtrees(a,t)); 
		case a:\method(t,n, p, e)  		:	dict += hash(dict, GroupTrees(Subtrees(a,0), t)); // hash(dict, Subtrees(a,t)); 
	}
	return dict;
}

public list[node] GetMethods(loc project)
{
	ast = AST(project);
	list[node] dict = [];
	top-down visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += a; 
		case a:\method(r,n, p, e, s) 	:	dict += a; 
		case a:\method(t,n, p, e)  		:	dict += a;  
	}
	return dict;
}

public void GetSubTrees(loc project, int t)
{
	l = GetMethods(project);
	newL = [];
	for (i <- l) {
		newL += Subtrees(i, t);
	}
	list[tuple[node,int]] k = GroupTrees(newL, 80);
	for (tuple[node a,int b] r <- k) {
		println(r.a);
		println("size : <r.b>");
	}
}

// Since single statments will normally not be grouped together (only in block statements) we have to do it manually
public list[tuple[node,int]] GroupTrees(list[tuple[node,int]] subtrees, int t) 
{
	list[tuple[node,int]] newList = [];
	list[tuple[node,int]] statements = [];
	for (tuple[node a,int b] l <- subtrees) {
		switch(l.a) {
			case \block(b)	: 	
			{ 
				newList += MakeBlocks(statements, t); 
				//newList += Sublists(statements, t);
				if (l.b >= t)
					newList += l;
				statements = [];
			}
			default 		:	statements += l;
		}
	}
	return newList;
}

public list[tuple[node,int]] MakeBlocks(list[tuple[node,int]] statements, int t)
{
	newList = [];
	int s = 0;		// Size of the block
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (tuple[node a, int b] i <- statements) {
		switch(i.a) {
			case Statement x:	
			{
				tempList = [];
				int q = 0;
				while (q + c < boundary) {
					tuple[node a, int b] newTup = statements[c + q]; 
					s += newTup.b;
					tempList += newTup;
					q += 1;
				}
				if (s >= t) {
					newList += MakeBlock(tempList);
				}
			}
		}
		c += 1;
		s = 0;
	}
	return newList;
}

public tuple[node, int] MakeBlock(list[tuple[node,int]] statements)
{
	list[Statement] newStatements = [];
	int s = 0;
	int length = 0;
	int endLine = 0;
	int endColumn = 0;
	
	// Get location
	tuple[node a ,int b] first = statements[0];
	loc location;
	loc last;
	switch(first.a) {
		case Statement b : { location = b@src; last = b@src;}
	}
	for (tuple[node a, int b] i <- statements) {
		switch(i.a) {
			case Statement b :
			{
				s += i.b;
				newStatements += b;
				endLine = b@src.end.line;
				endColumn = b@src.end.column;
				last = b@src;
			}
		}
	}
	length = last.offset - location.offset + last.length;
	// Create new tuple
	Statement statement = \block(newStatements);
	statement@src = location(location.offset,length,<location.begin.line,location.begin.column>,<endLine,endColumn>);
	return <statement, s>;
}

// Create map and hash the subtrees
private map[node, list[node]] hash (map[node, list[node]] dict, list[tuple[node,int]] trees)
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
				if (temp == false)
					dict += (n : dict[n] + n);
				}
				else
					dict += (n : [n]);
			}
		}
	}
	return dict;
}

public void PrintTrees(loc project, int t)
{
	int sm =0;
	ast = AST(project);
	map[node,list[node]] trees = Subclones2(filterClones(MethodTrees(ast, t)));
	int i =0;
	for(node a <- trees) {
		i += 1;
		top-down-break visit(trees[a]) {
			case Statement b 	: 	println("<i> : <b@src>");
		}
	}
}

// Filter out only subtrees with multiple instances (clones)
private map[node,list[node]] filterClones(map[node,list[node]] trees)
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

private int sum(list[tuple[node,int]] l) 
{
	s = 0;
	for (tuple[node a, int b] i <- l) {
		s += i.b;
	}
	return s;
}

// Get all sublists with at least size t
private list[tuple[node,int]] Sublists(list[tuple[node, int]] l, int t)
{
	lists = [];
	for (i <- [0..size(l)]) {
		sub = [];
		s = 0;
		for (j <- [i..size(l)]) {
			if (i <= j) {
				tuple[node a, int b] tup = l[i];
				switch(tup.a) {
					case Statement b : 
					{
						sub += l[j];
						s += tup.b;
						if (s >= t)
							lists += MakeBlock(sub);
					}
				}
			}
			//else { break; }
		}
	}
	return lists;
}
