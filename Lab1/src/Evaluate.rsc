module Evaluate

// Extraction methods remain the same, but grading them can differ, therefore this is in a separate module

import Complexity;
import CodeLines;
import Volume;
import FilesHandling;

public str EvaluateVolume(int amount)
{
	str evaluation;
	if (amount < 66000)
		evaluation = "++";
	else if (amount < 246000)
		evaluation = "+";
	else if (amount < 665000)
		evaluation = "0";
	else if (amount < 1310000)
		evaluation = "-";
	else
		evaluation = "--";
	return evaluation;
}

public str EvaluateComplexity(map[str, real] table)
{
	str evaluation;
	if (table["Very high risk"] == 0 && table["High risk"] == 0 && table["Moderate risk"] <= 25)
		evaluation = "++";
	else if (table["Very high risk"] == 0 && table["High risk"] <= 5 && table["Moderate risk"] <= 30)
		evaluation = "+";
	else if (table["Very high risk"] == 0 && table["High risk"] <= 10 && table["Moderate risk"] <= 40)
		evaluation = "0";
	else if (table["Very high risk"] == 5 && table["High risk"] <= 15 && table["Moderate risk"] <= 50)
		evaluation = "-";
	else
		evaluation = "--";
	return evaluation;
}
	