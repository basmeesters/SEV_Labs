module Complexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;

public map[loc, int] Complexity(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return Complexity(dcs);
}

public map[loc, int] Complexity(set[Declaration] dcs)
{
	// Each method (or constructor) is a unit of which we want to know the complexity
	map[loc, int] dict = ();
	for (d <- dcs)
	{
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: dict += (a@src : ComplexityInMethod(s)); 
			case a:\method(_,_,_,_,Statement s) 	: dict += (a@src : ComplexityInMethod(s)); 
			case a:\method(_,_,_,_)					: dict += (a@src : 1); // Just exceptions
		}
	}
	return dict;
}

int ComplexityInMethod(Statement s)
{
	// Base complexity = 1
	int count = 1;
	
	// For each of the following in the Statment (method) add one for complexity
	visit(s)
	{
		case \for(_,_,_) 		: count += 1; 
		case \for(_,_,_,_)  	: count += 1;
		case \foreach(_,_,_) 	: count += 1;
		case \while(_,_) 		: count += 1;
		case \do(_,_) 			: count += 1;
		case \if(_,_) 			: count += 1;
		case \if(_,_,_) 		: count += 1;
		case \case(_) 			: count += 1;
		case \catch(_,_)		: count += 1;
		case \conditional(_,_,_): count += 1;
		case \infix(_,"&&",_) 	: count += 1;
		case \infix(_,"||",_) 	: count += 1;
	}
	return count;
}