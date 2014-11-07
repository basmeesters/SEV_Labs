module Complexity

import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

public loc project = |project://Hello|;
public M3 model = createM3FromEclipseProject(project);

public int cyclomaticComplexity(Graph[&T] PRED){
 return size(PRED) - size(carrier(PRED)) + 2;
}

public set[loc] containMain() {return model@containment[|java+class:///testPack/Main|]; }
public rel[loc from, loc to] contain = model@containment;


public set[Declaration] decls = createAstsFromEclipseProject(project,true);

public int complexity(set[Declaration] dcs)
{
	int count = 1;
	for (d <- dcs)
	{
		visit (d) {
			case \constructor(_, _,_, Statement s): count += complexityStatement(s); 
			case \method(_,_,_,_,Statement s) : count += complexityStatement(s); 
			case \method(_,_,_,_): count += 1;
		}
	}
	return count;
}

public int complexityStatement(Statement s)
{
	int count = 1;
	visit(s)
	{
		case \if(_, _):
			count += 1;
		case \if(_, _, _):
			count += 1;
		case \case(_):
			count += 1;
		case \while(_, _):
			count += 1;
		case \foreach(_, _, _):
			count += 1;
		case \for(_, _, _, _):
			count += 1;
		case \for(_, _, _):
			count += 1;
		case \catch(_, _):
			count += 1;
		case  \try(_,_) : 
			count += 1;
        case \try(_,_,_) : 
        	count += 1;
		case \infix(_, operator, _, _):
			if(operator == "&&" || operator == "||") count += 1;
		case \conditional(_, _, _):
			count += 1;
	}
	
	return count;
}

public Declaration methodAST = getMethodASTEclipse(|java+method:///testPack/Main/main(java.lang.String%5B%5D)|, model=model);
//public int exprCount(Declaration d) {return (0 | it + 1 | /Expression _ := d); }

// set[loc] contain() {return myModel@containment[|java+class:///Main|]; }
// list[loc] methods() {return [ e | e <- myModel@containment[|java+class:///Main|], e.scheme == "java+method"];; }

public list[loc] locations = [m@src | /Expression m := methodAST];

// Extract information
public list[loc] classes = [ e | e <- model@containment[|java+package:///testPack|]];
public list[loc] methods = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+method"];
public list[loc] fields = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+field"];

// methods of the whole package
//public list[loc] methods2 = methods(model);
// BTW, The "uses" and "declarations" relations together can be combined to get a graph that links uses to definition sites, i.e. `m@uses o m@declarations`.