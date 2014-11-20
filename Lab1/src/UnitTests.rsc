module UnitTests

import CodeLines;
import List;
import String;
import Volume;
import Complexity;
import Risk;

public loc file = |project://Hello/src/testPack/Unit.java|;
public loc file2 = |project://Hello/src/testPack/Test.java|;
public loc project = |project://Hello|;
// Automated
public bool Test()
{
	return CorrectLOC && 
	       CorrectVolume && 
	       CorrectUnitVolume && 
	       CorrectComplexity && 
	       CorrectRisk;
}

// Test CodeLines
public bool CorrectLOC()
{
	list[str] singleComment = ["package testPack; // something","public class Unit {","public Unit()","{","//something","int i = 1;","someMethod();","}","public void someMethod(){ ","String i = \"\";","}","}"];
	list[str] singleCommentRemoved = ["package testPack; ","public class Unit {","public Unit()","{","int i = 1;","someMethod();","}","public void someMethod(){","}","}"];
	bool single = CleanCode(singleComment) == singleCommentRemoved;
	
	list[str] multiLineComment = ["package testPack; // something","public class Unit {","public Unit()","{","\t/*                  */","int i = 1;","someMethod();","}","/*"," * "," * "," */","public void someMethod(){ ","String i = \"\";","}","}"];
	list[str] multiLineCommentRemoved = ["package testPack; ","public class Unit {","public Unit()","{","int i = 1;","someMethod();","}","public void someMethod(){","}","}"];
	bool multi = CleanCode(multiLineComment) == multiLineCommentRemoved;
	
	list[str] stringComment = ["package testPack;","public class Unit {","public Unit()","{","int i = 1;","someMethod();","}","public void someMethod(){ ","String i = \"/* no comment but the opening looks like it\";","int q = 0;","String j = \"blaa */\";","}","}"];
	list[str] stringCommentRemoved = ["package testPack;","public class Unit {","public Unit()","{","int i = 1;","someMethod();","}","public void someMethod(){","String i = \"\";","int q = 0;","String j = \"\";","}","}"];
	bool comment = CleanCode(stringComment) == stringCommentRemoved;
	
	return single && multi;// && comment;
}

// Test Volume
public bool CorrectVolume()
{ 
	int m = LinesOfCode(file);
	bool f1 = m == 13;
	
	int m2 = LinesOfCode(file2);
	bool f2 = m2 == 21;
	
	return f1 && f2;
}

public bool CorrectUnitVolume()
{
	map[loc, int] codePerUnit = LinesPerUnit(project);
	list[int] amounts = [];
	for (i <- codePerUnit) {
		amounts += codePerUnit[i];
	}
	bool b = amounts == [11,4,5,5,6,11,3,11,1,7];
	return b;
}

// Test Complexity
public bool CorrectComplexity()
{
	map[loc,int] complexity = Complexity(project);
	list[int] amounts = [];
	for (i <- complexity) {
		amounts += complexity[i];
	}
	bool b = amounts == [3,1,1,1,2,1,1,1,7,2];
	return b;
}

// Test Risk
public bool CorrectRisk()
{
	int total = LinesOfCode(project);
	map[loc, int] codePerUnit = LinesPerUnit(project);
	map[loc,int] complexity = Complexity(project);
	list[int] amounts = [];
	map[str, real] r =  RiskComplexity(complexity, codePerUnit, total);
	bool b = r["No risk"] == 100.00000000000 &&
			 r["Moderate risk"]		== 0.0 &&
			 r["High risk"]			== 0.0 &&
			 r["Very high risk"] == 0.0;
    return b;
}