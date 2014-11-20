module Evaluate

// Extraction methods remain the same, but grading them can differ, therefore this is in a separate module

import Complexity;
import CodeLines;
import Volume;
import FilesHandling;

// Standard borders to evaluate total size, duplication amount and testing coverage
list[int] bordersVolume = [66000, 246000, 665000, 1310000];
list[int] bordersDuplication = [3, 5, 10, 20];
list[int] bordersTesting = [20, 60, 80, 95];

public str EvaluateDuplicates(int amount) {
	return EvaluateList(amount, bordersDuplication);
}

public str EvaluateDuplicates(int amount, list[int] borders) {
	return EvaluateList(amount, borders);
}

public str EvaluateVolume(int amount) {
	return EvaluateList(amount, bordersVolume);
}

// Evaluate a value based on a list of given borders
public str EvaluateList(int amount, list[int] borders) {
	str evaluation;
	if (amount < borders[0])
		evaluation = "++";
	else if (amount < borders[1])
		evaluation = "+";
	else if (amount < borders[2])
		evaluation = "0";
	else if (amount < borders[3])
		evaluation = "-";
	else
		evaluation = "--";
	return evaluation;
}

// Evaluate a table
public str EvaluateTable(map[str, real] table)
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