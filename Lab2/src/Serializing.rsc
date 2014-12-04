module Serializing

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;

// The project locations
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;

// Just a shorter variant 
public set[Declaration] AST(loc project)
{
	return createAstsFromEclipseProject(project,true);
}

// One declaration for each file
public set[Declaration] SerializedAST(loc project)
{
	return SerializedAST(AST(project));
}

// Serialize the AST by replacing variable and method names
public set[Declaration] SerializedAST(set[Declaration] ast)
{
	// Guy, for you, this deep visit goes through the whole ast and everytime one of the below matches does the 
	// operation after the =>
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

public list[value] TreeSize(set[Declaration] dcs)
{
	l = [];
	visit(dcs) {
		case a:\constructor(n, p, e, s)	:	
		{
			l += Check(a);	
		}
		case a:\method(r,n, p, e, s) 	:	
		{
			l += return Check(a);	
		}
		case a:\method(t,n, p, e)  		:	
		{
			;	
		}
    	
	}
	return l;
}

// Guy, for you again, this code is not useful but shows how you can also pattern match on terminals (instead of non terminals)
// See the Java grammar for more information:
// https://github.com/cwi-swat/rascal/blob/master/src/org/rascalmpl/library/lang/java/m3/AST.rsc
public list[list[value]] Check(value d)
{
	// The initial idea was to count the number of children but failed..
	int size = 0;
	list [value] current = [];
	list [value] total = [];
	bottom-up visit(d) {
		case b:Statement _	: 
		{
			size += 1;
			if (size > 7)
				return l;
			else {
				current += b;
				total += Check(b);
			}
		}
		case b:Expression _ :
		{
			size += 1;
			if (size > 7)
				return l;
			else {
				current += b;
				total += Check(b);
			}
		}
		case b:Type _ :
		{
			size += 1;
			if (size > 7)
				return l;
			else {
				current += b;
				//total += Check(b);
			}
		}
		case b:Declaration _:
		{
			size += 1;
			if (size > 7)
				return l;
			else {
				current += b;
				total += Check(b);
			}
		}
		case b:Modifier _:
		{
			size += 1;
			if (size > 7)
				return l;
			else {
				current += b;
				total += Check(b);
			}
		}
	}
	total += current;
	return total;
}

// Get all subtrees within methods / constructors
public void SubTrees(set[Declaration] ast)
{
	l = [];
	visit(ast) {
		case a:\constructor(n, p, e, s)	:	
		{
			e = Elements(a);
			println(e);			// the subtrees in the form of <node, children amount> 
			println(size(e));	// the amount of subtrees
		}
		case a:\method(r,n, p, e, s) 	:	
		{
			list[tuple[node,int]] e = Elements(a);
			println(e);	
			println(size(e));
		}
		case a:\method(t,n, p, e)  		:	
		{
			e = Elements(a);
			println(e);	
			println(size(e));
		}
	}
	
}

// Get all the subtrees given a node 
public list[tuple[node,int]] Elements(node a)
{
	return trees = [<n,(0|it+1|/node _ <-n)> | /node n <- a];
}
