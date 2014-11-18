module Risk

import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

// Standard lists of how to divide amounts in categories for volume and complexity
public list[int] VolumeUnitsMetrics = [20, 50, 100];
public list[int] ComplexityMetrics = [10, 20, 50];

public map[str, real] RiskVolume(map[loc, int] units, int total) {
	return RiskPercentage(RiskTable(units, VolumeUnitsMetrics), units, total);
}

public map[str, real] RiskComplexity(map[loc, int] complexity, map[loc, int] units, int total) {
	return RiskPercentage(RiskTable(complexity, ComplexityMetrics), units, total);
}

public map[str, real] RiskPercentage(map[loc, int] riskTable, map[loc, int] units, int total){
	real veryHighRisk = 0.0;
	real highRisk = 0.0;
	real risk = 0.0;
	real noRisk = 0.0;
	real totalAmount = 0.0;
	for (i <- riskTable)
	{
		int size = units[i];
		real lineAmount = toReal(size); 
		real percentage = (lineAmount / total) * 100;
		if (riskTable[i] == 3)
			veryHighRisk += percentage;
		else if (riskTable[i] == 2)
			highRisk += percentage;
		else if (riskTable[i] == 1)
			risk += percentage;
		else {
			noRisk += percentage; 
		totalAmount += percentage;
		}
	}
	println("total:<totalAmount>");
	noRisk += (100.00 - totalAmount);
	// If the totalAmount is not 100% it is probably because of import and field lines which are in the noRisk category
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