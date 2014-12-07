module AST::Serializing

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

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


