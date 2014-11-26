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
import DateTime;
import util::Math;


// Projects
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;
	
// Extract method
public void Extract(loc project, bool log)
{
	Extract(project, log, createAstsFromEclipseProject(project,true));
}

public void Extract(loc project, bool log, set[Declaration] dcls)
{
	time = now();

	// All useful lines of code (no comments or blank lines)
	map[loc, list[str]] codeUnits = CodePerFile(project);
	
	// Duplicates
	map[str, list[tuple[loc, int, int]]] duplicates = DuplicatesAnalyzer(5, codeUnits);
	int duplicationCounter = DuplicateLinesCounter(duplicates);
	
	//Lines of code total
	int totalVolume = LinesOfCode(codeUnits);
	
	// Lines of code per unit
	map[loc, int] volume = LinesPerUnit(project);
	map[str, real] riskLevelVolume = RiskVolume(volume, totalVolume);

	// Cyclomatic complexity per unit
	map[loc, int] complexity = Complexity(dcls);
	map[str, real] riskLevelComplexity = RiskComplexity(complexity, volume, totalVolume);
	
	if (log) {
		str p = replaceAll(replaceAll(locToStr(project), "|", ""), "/", "_");
		loc file = |project://Lab1/<p>.txt|;
		appendToFile(file, "Measure project at: <time>\n\n");
		Results(totalVolume, riskLevelVolume, riskLevelComplexity, duplicationCounter, void (str string){appendToFile(file, string);});
		appendToFile(file, "<createDuration(time, now())>\n-----------------------------------------------------\n\n");
	}
	else 
		Results(totalVolume, riskLevelVolume, riskLevelComplexity, duplicationCounter, print);
}

public void Results(int total, map[str, real] volumeRisk, map[str, real] complexityRisk, int duplicationCounter, void (str) log)
{
	str volume = EvaluateVolume(total);
	log("The total LOC amount is: <total>, which gives score <volume>\n\n");
	
	for (i <- volumeRisk) {
		log("<i> percentage is: <volumeRisk[i]>\n");
	}
	str unitvolume = EvaluateTable(volumeRisk);
	log("\nThe score for unit size is: <unitvolume>\n\n");
	
	for (i <- complexityRisk) {
		log("<i> risk percentage is: <complexityRisk[i]>\n");
	}
	str complexity = EvaluateTable(complexityRisk);
	log("\nThe score for complexity per unit is: <complexity>\n\n");
	
	real average = toReal(duplicationCounter) / toReal(total) * 100.0;
	str duplication = EvaluateDuplicates(toInt(average), total);
	
	log("The percentage of duplication is: <average>\n");
	log("The score of duplication is: <duplication>\n\n");
	str analysability = CountScores([volume, duplication, unitvolume]);
	str changability = CountScores([complexity, duplication]);
	str testability = CountScores([complexity, unitvolume]);
	log("score for analysability is: volume(<volume>) & unit volume(<unitvolume>) &" +
	     " duplication(<duplication>)= <analysability>\n"); // unit testing & duplication
	log("score for changeability is: complexity(<complexity>) & duplication(<duplication>)= <changability>\n"); // duplication
	log("score for testability is: complexity(<complexity>) & unit volume(<unitvolume>) = <testability>\n"); // unit testing
	log("score for maintainability is: analysability (<analysability>)" 
	     + " & changability(<changability>) & testability(<testability>) = "
	     + "<CountScores([analysability,changability,testability ])>\n");
}	

// Create a new score given a list of scores, each weights the same
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
	if (newScore <= -2)
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