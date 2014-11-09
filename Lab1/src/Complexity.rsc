module Complexity

import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import CodeLines;
import util::Math;

public map[loc, int] Complexity(set[Declaration] dcs)
{
	map[loc, int] dict = ();
	for (d <- dcs)
	{
		int count = 0;
		visit (d) {
			case \constructor(_, _,_, Statement s): count += complexityStatement(s); 
			case \method(_,_,_,_,Statement s) : count += complexityStatement(s); 
			case \method(_,_,_,_): count += 1;
		}
		dict += (d@decl : count);
	}
	return dict;
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

public map[loc, int] Risk(set[Declaration] dcs)
{
	map[loc, int] dict = Complexity(dcs);
	map[loc, int] risk = ();
	for (m <- dict)
	{
		int r;
		if (dict[m] < 10)
			r = 0;
		else if (dict[m] < 20)
			r = 1;
		else if (dict[m] < 50)
			r = 2;
		else
			r = 3;
		risk += (m: r);
	}
	return risk;
}

public map[str, real] RiskPercentage(set[Declaration] dcs, int total)
{
	map[loc, int] riskTable = Risk(dcs);
	println(riskTable);

	real veryHighRisk = 0.0;
	real highRisk = 0.0;
	real risk = 0.0;
	real noRisk = 0.0;
	
	for (i <- riskTable)
	{
		real lineAmount = toReal(linesOfCode(i)); // Not very efficient to do this multiple times
		println("line amount:<lineAmount>");
		if (riskTable[i] == 3)
			veryHighRisk += (lineAmount / total) * 100;
		else if (riskTable[i] == 2)
			highRisk += (lineAmount / total) * 100;
		else if (riskTable[i] == 1)
			risk += (lineAmount / total) * 100;
		else {
			noRisk += (lineAmount / total)* 100; println(<noRisk>);}
	}
	
	return ("No risk":noRisk, "Moderate risk":risk, "High risk":highRisk, "Very high risk":veryHighRisk);
}