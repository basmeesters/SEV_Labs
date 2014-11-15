module Main

import FilesHandling;
import Complexity;
import Volume;
import Set;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Evaluate;
import Risk;
import Duplication;
import IO;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
	
// Extract method
public list[str] Extract(loc project)
{
	// All useful lines of code (no comments or blank lines)
	map[loc, list[str]] codeUnits = CodeUnits(project);
	
	// Lines of code per unit
	map[loc, int] volume = CountUnits(project);
	
	//Lines of code total
	int totalVolume = CountCode(codeUnits);
	
	// Cyclomatic complexity per unit
	set[Declaration] dcls = createAstsFromEclipseProject(project,true);
	map[loc, int] complexity = Complexity(dcls);
	map[str, real] riskLevelComplexity = RiskComplexity(complexity, volume, totalVolume);
	map[str, real] riskLevelVolume = RiskVolume(volume, totalVolume);
	
	// duplications
	//map[str, list[tuple[loc, int, int]]] duplications = DuplicatesAnalyzer(project, "java", 6);
	//int totalDups = DuplicateLinesCounter(duplications);
	
	//str duplicationEvaluated = EvaluateDuplicates(totalDups, totalVolume);
	str volumeEvaluated = EvaluateVolume(totalVolume);
	str complexityEvaluated = EvaluateTable(riskLevelComplexity);
	str volumeUnitEvaluated = EvaluateTable(riskLevelVolume);
	return [volumeEvaluated, complexityEvaluated, volumeUnitEvaluated];
}

// Debugging purposes only
public void Check()
{
	// All useful lines of code (no comments or blank lines)
	map[loc, list[str]] codeUnits = CodeUnits(small);
	
	// Lines of code per unit
	map[loc, int] volume = CountUnits(small);
	
	//Lines of code total
	int totalVolume = CountCode(codeUnits);
	set[Declaration] dcls = createAstsFromEclipseProject(small,true);
	map[loc, int] complexity = Complexity(dcls);
	map[str, real] riskLevelComplexity = RiskComplexity(complexity, volume, totalVolume);
	println(riskLevelComplexity);
}