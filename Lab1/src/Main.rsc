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

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

// Example Declarations
public set[Declaration] simpleDecls = createAstsFromEclipseProject(simple,true);
public set[Declaration] smallDecls = createAstsFromEclipseProject(small,true);
	
// Extract method
public list[str] Extract(loc project, str ext)
{
	// All useful lines of code (no comments or blank lines)
	map[loc, list[str]] codeUnits = CodeUnits(project, ext);
	
	// Lines of code per unit
	map[loc, int] volume = CountUnits(codeUnits);
	
	//Lines of code total
	int totalVolume = CountCode(codeUnits);
	
	// Cyclomatic complexity per unit
	set[Declaration] dcls = createAstsFromEclipseProject(project,true);
	map[loc, int] complexity = Complexity(dcls);
	map[str, real] riskLevelComplexity = RiskComplexity(dcls, volume, totalVolume);
	map[str, real] riskLevelVolume = RiskVolume(volume, totalVolume);
	
	str volumeEvaluated = EvaluateVolume(totalVolume);
	str complexityEvaluated = EvaluateTable(riskLevelComplexity);
	str volumeUnitEvaluated = EvaluateTable(riskLevelVolume);
	return [volumeEvaluated, complexityEvaluated, volumeUnitEvaluated];
}