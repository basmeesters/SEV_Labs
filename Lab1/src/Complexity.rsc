module Complexity

import analysis::graphs::Graph;
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
	
	map[loc, int] dict = ();
	//println(dcs);
	for (d <- dcs)
	{
		visit (d) {
			case a:\constructor(_,_,_,Statement s)	: dict += (a@decl : complexityMethod(s)); 
			case a:\method(_,_,_,_,Statement s) 	: dict += (a@decl : complexityMethod(s)); 
			case a:\method(_,_,_,_)					: dict += (a@decl : 1); 
		}
	}
	return dict;
}

public int complexityMethod(Statement s)
{
	int count = 1;
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
		case \try(_,_)			: count += 1;
		case \try(_,_,_)	    : count += 1;
		case \conditional(_,_,_): count += 1;
		case \infix(_,"&&",_) 	: count += 1;
		case \infix(_,"||",_) 	: count += 1;
	}
	return count;
}