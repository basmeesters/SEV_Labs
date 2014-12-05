module Serializing

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;

// The project locations
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// One declaration for each file
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

// https://github.com/cwi-swat/rascal/blob/master/src/org/rascalmpl/library/lang/java/m3/AST.rsc
public list[list[value]] Check(value d)
{
	// The initial idea was to count the number of children but failed..
	int size = 0;
	list [value] current = [];
	list [value] total = [];
	bottom-up visit(d) {
		case b:Statement _	: ;
		case b:Expression _ : ;
		case b:Type _ :;
		case b:Declaration _:;
		case b:Modifier _:;
	}
	total += current;
	return total;
}

// Get all the subtrees given a node 
private list[tuple[node,int]] Subtrees(node a, int t) = [<n,s> | /node n <- a, s <- [SizeTree(n)], s >= t];
private int SizeTree(node n) = (0|it+1|/node _ <-n);

// Get all subtrees within methods / constructors
public map[tuple[node,int], int] MethodTrees(set[Declaration] ast, int t)
{
	dict = ();
	visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += hash(dict, Subtrees(a,t)) ;
		case a:\method(r,n, p, e, s) 	:	dict += hash(dict, Subtrees(a,t)) ;
		case a:\method(t,n, p, e)  		:	dict += hash(dict, Subtrees(a,t)) ;
	}
	return dict;
}

private map[tuple[node,int], int] hash (map[tuple[node,int], int] dict, list[tuple[node,int]] trees)
{
	newD = ();
	for (tuple[node,int] l <- trees) {
		if (l in dict) {
			newD += (l : dict[l] + 1);
			println("dup!");
		}
		else {
			newD += (l : 1);
			println("new!");
		}
	}
	return newD;
}

public void printTrees(loc project, int t)
{
	ast = AST(project);
	trees = MethodTrees(ast, t);
	for(tuple[node a, int b] l <- trees)
		println("size : <l.b>, amount = <trees[l]>, tree: <l.a>");
}
