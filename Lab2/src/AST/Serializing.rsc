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

// https://github.com/cwi-swat/rascal/blob/master/src/org/rascalmpl/library/lang/java/m3/AST.rsc
// Serialize the AST by replacing variable and method names using the java grammar from the link above
public set[Declaration] SerializedAST(loc project) = SerializedAST(AST(project));
public set[Declaration] SerializedAST(Declaration d) = SerializedAST(SerializedAST({d}));
public set[Declaration] SerializedAST(set[Declaration] ast) 
{
	return visit (ast) 
	{
		case a:\simpleName(name) 					=> {b = \simpleName("var"); b@src = a@src; }
		case a:\constructor(name, p, e, s)			=> {b = \constructor("constructor",p,e,s); b@src = a@src; } 
		case a:\method(r,name, p, e, s) 			=> {b = \method(r,"function", p, e, s); b@src = a@src; } 
		case a:\method(t,name, p, e)  				=> {b = \method(t,"function", p, e); b@src = a@src; }
		case a:\parameter(t, name, e)				=> {b = \parameter(t, "x", e); b@src = a@src; }	
		case a:\variable(name, e)					=> {b = \variable("var", e)	; b@src = a@src; }
    	case a:\variable(name, e, i)				=> {b = \variable("var", e, i); b@src = a@src; }	
    	case a:\type(TypeSymbol)					=> a
    	case a:\type(Type t)						=> {b = \type(\int()); b@src = a@src; }
	}
}


