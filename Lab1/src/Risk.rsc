module Risk

import CodeLines;
import FilesHandling;
import String;
import Volume;
import List;
import Complexity;
import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

// For debugging
//
public map[str, real] RiskVolume(loc project)
{
	map[loc, int] codeCount = CountUnits(project, "java");
	return RiskVolume(codeCount, CountCode(codeCount));
}

public map[str, real] RiskComplexity(loc project)
{
	set[Declaration] dcs = createAstsFromEclipseProject(project,true);
	map[loc, int] codeCount = CountUnits(project, "java");
	return RiskComplexity(dcs, codeCount, CountCode(codeCount));
}
//
// End debugging

public list[int] VolumeUnitsMetrics = [20, 50, 100];
public list[int] ComplexityMetrics = [10, 20, 50];


public map[str, real] RiskVolume(map[loc, int] units, int total)
{
	return RiskPercentage(RiskTable(units, VolumeUnitsMetrics), total);
}

public map[str, real] RiskComplexity(set[Declaration] dcs, map[loc, int] units, int total)
{
	return RiskPercentage(RiskTable(Complexity(dcs), ComplexityMetrics), total);
}

public map[str, real] RiskPercentage(map[loc, int] riskTable, int total)
{
	real veryHighRisk = 0.0;
	real highRisk = 0.0;
	real risk = 0.0;
	real noRisk = 0.0;
	for (i <- riskTable)
	{
		list[str] code = CleanCode(i);
		int size = size(code);
		real lineAmount = toReal(size); // This needs some change..
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

public map[loc, int] RiskTable(map[loc,int] units, list[int] borders)
{
	map[loc, int] risk = ();
	for (m <- units)
	{
		int r;
		if (units[m] < borders[0]) 
			r = 0;
		else if (units[m] < borders[1])
			r = 1;
		else if (units[m] < borders[2]) 
			r = 2;
		else
			r = 3;
		risk += (m: r);
	}
	return risk;
}