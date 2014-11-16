module Main

import FilesHandling;
import Complexity;
import Volume;
import List;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Evaluate;
import Risk;
import Duplication;
import IO;
import util::FileSystem;

// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
	
// Extract method
public void Extract(loc project, bool log)
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
	
	if (log) {
		str p = replaceAll(locToStr(project), "|", "");
		loc file = |project://Lab1/Log<p>.txt|;
		Results(totalVolume, riskLevelVolume, riskLevelComplexity, void (str string){appendToFile(file, string);});
	}
	else 
		Results(totalVolume, riskLevelVolume, riskLevelComplexity, print);
	// duplications
	//map[str, list[tuple[loc, int, int]]] duplications = DuplicatesAnalyzer(project, "java", 6);
	//int totalDups = DuplicateLinesCounter(duplications);
	
	//str duplicationEvaluated = EvaluateDuplicates(totalDups, totalVolume);

	//return [volumeEvaluated, complexityEvaluated, volumeUnitEvaluated];
}

public void Results(int total, map[str, real] volumeRisk, map[str, real] complexityRisk, void (str) log)
{
	str volume = EvaluateVolume(total);
	log("The total LOC amount is: <total>, which gives score <volume>\n");
	
	for (i <- volumeRisk) {
		log("<i> percentage is: <volumeRisk[i]>\n");
	}
	str unitvolume = EvaluateTable(volumeRisk);
	log("The score for unit size is: <unitvolume>\n");
	
	for (i <- complexityRisk) {
		log("<i> risk percentage is: <complexityRisk[i]>\n");
	}
	str complexity = EvaluateTable(complexityRisk);
	log("The score for complexity per unit is: <complexity>\n");
	
	log("score for analysability is: <volume> & <unitvolume> = <CountScores([volume, unitvolume])>\n"); // unit testing & duplication
	log("score for changeability is: <complexity> = <CountScores([complexity])>\n"); // duplication
	log("score for testability is: <complexity> & <unitvolume> = <CountScores([complexity, unitvolume])>\n"); // unit testing
	//println("score for maintainability is: <volume> + <unitvolume> = <CountScores([volume, unitvolume])>");
	
	// Stability = unit testing
}	

public str CountScores(list[str] scores)
{
	str result;
	int score = 0;
	visit(scores)
	{
		case "++" : score += 2;
		case "+" : score += 1;
		case "-" : score -= 1;
		case "--" : score -= 2;
	}
	newScore = score / size(scores);
	if (newScore < -2)
		result = "--";
	else if (newScore == -1)
		result = "-";
	else if (newScore == 0)
		result = "0";
	else if (newScore == 1)
		result = "+";
	else 
		result = "++";
	return result;
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