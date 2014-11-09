module Complexity

import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Volume;
import util::Math;
import CodeLines;
import List;

public map[loc, int] Complexity(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	return Complexity(dcs);
}

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
		dict += (d@src : count);
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

public map[str, real] RiskPercentage(loc project, str ext)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	map[loc, int] codeCount = CountUnits(project, ext);
	return RiskPercentage(dcs, codeCount, CountCode(codeCount));
}

// Example: |project//smalsql0.21_src
// map[str, real]: ("Very high risk":58.1930995568600,"Moderate risk":11.093353389300,"High risk":20.550907211700,"No risk":10.1626398418700)

public map[str, real] RiskPercentage(set[Declaration] dcs, map[loc, int] codeCount, int total)
{
	map[loc, int] riskTable = Risk(dcs);

	real veryHighRisk = 0.0;
	real highRisk = 0.0;
	real risk = 0.0;
	real noRisk = 0.0;
	
	for (i <- riskTable)
	{
		real lineAmount = toReal(size(LinesOfCode(i))); // This needs some change..
		if (riskTable[i] == 3)
			veryHighRisk += (lineAmount / total) * 100;
		else if (riskTable[i] == 2)
			highRisk += (lineAmount / total) * 100;
		else if (riskTable[i] == 1)
			risk += (lineAmount / total) * 100;
		else {
			noRisk += (lineAmount / total)* 100; 
		}
	}
	
	return ("No risk":noRisk, "Moderate risk":risk, "High risk":highRisk, "Very high risk":veryHighRisk);
}

public map[loc, int] Risk(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(simple,true);
	return Risk(dcs);
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