module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import Map;
import Set;
import Exception;
import DateTime;

public int DuplicateLinesCounter(map[str, list[tuple[loc a, int b, int c]]] duplicates) {
	int counter = 0;
	for(dupKey <- duplicates) {
		dupValues = duplicates[dupKey];
		for(dupVal <- dupValues){
			//filePath = dupVal.a;
			fromLine = dupVal.b;
			toLine = dupVal.c;
			lines = toLine-fromLine;
			counter += lines;
		}
	}
	return counter;
}

//public map[str, list[tuple[loc, int, int]]] DuplicatesAnalyzer(loc dirPath, str fileExt, int blockSize) {
//	list[loc] files = getFiles(dirPath, fileExt);
//	map[loc, list[str]] filesCode = ();
//	for(filePath <- files) {
//		filesCode = (filePath : CleanCode(filePath));
//	}
//	
//	return DuplicatesAnalyzer(filesCode, blockSize);
//}

public map[str, list[tuple[loc, int, int]]] DuplicatesAnalyzer(int blockSize, map[loc, list[str]] codeUnits) {

	//// timer
	//	totaltime = now();
	//	timer = now();
	//	println("=====\n\rfind duplicates area");
	//// timerEnd
	if(blockSize < 1)
		throw "blockSize must be greater than zero!";
	//list[loc] files = getFiles(dirPath, fileExt);
	map[str, list[tuple[loc, int, int]]] blocks = ();
	map[str, list[tuple[loc a, int b, int c]]] duplicates = ();
	//map[loc, list[str]] filesWithDups = ();
	
	for(filePath <- codeUnits) {
	
		list[str] code = codeUnits[filePath];
		str tempBlock = "";
		list[tuple[loc, int, int]] tempList = [];
		
		int lineIndex = 0;
		int codeSize = size(code); // TEST ME ???
		int lastI = 0;
		bool isBreak = false;
		bool dupsExists = false;
		//filesWithDups += (filePath : code);
		
		for(line <- code) {
			// create blocks for each line
			lastI = 0;
			for(i <- [0..blockSize]) {
				lastI = i;
				if(i+lineIndex < codeSize)
					tempBlock += code[i+lineIndex];
				else { // if max line is reached. we can stop (otherwise it will create block with smaller than defined size
					isBreak = true;
					break;
				}
			}
			if(isBreak == true) {
				isBreak = false;
				break;
			}
			if(tempBlock notin blocks) {
				blocks += (tempBlock: [<filePath, lineIndex, lineIndex+lastI>]);
				//println((tempBlock: <filePath, lineIndex, lineIndex+lastI>));
				//println("---");
			}
			else { // if is duplicate, add it to duplicates map 
				//println((tempBlock: <filePath, lineIndex, lineIndex+lastI>));
				tuple[loc, int, int] currPos = <filePath, lineIndex, lineIndex+lastI>;
				list[tuple[loc, int, int]] prevsPos = blocks[tempBlock];
				//println(tempBlock);
				
				for(prevPos <- prevsPos) {
					tempList = [];
					//println(prevPos);
					tuple[str code, list[tuple[loc, int, int]] posList] expandDups = expandDupBlocksSmall(<tempBlock , <currPos, prevPos>>, codeUnits);
					tempList += expandDups.posList;
					if(expandDups.code in duplicates) {
						//println(tempList);
						tempList += duplicates[expandDups.code];
						//println(tempList);
						tempList = dup(tempList);
						duplicates[expandDups.code] = tempList;
						//println(tempList);
					}
					else {
						duplicates += (expandDups.code : tempList);
					}
					//println("--");
				}
				blocks[tempBlock] = currPos + blocks[tempBlock]; // add pos
				
				dupsExists = true;
			}
			tempBlock = "";
			
			lineIndex += 1;
		}
		
		dupsExists = false;
		//println("====");
	}
	
	//println(now()-timer);
	//println("=====\n\rremove overlaps");
	//timer = now();
			
	// remove overlapping lines boundaries
	// conLocs      [(<<12,19>> : code), (<<14,19>> : code), (<<26,30>> : code)]
	map[str, map[list[int], str]] tempMap = ();
	str locsKey = "";
	for(aggDupKey <- duplicates) {
		aggDupVal = duplicates[aggDupKey]; // code line
		mapOfLinesCode = ();
		tuple[loc a, int b, int c] lastVal;
		for(posVal <- aggDupVal) {
			locsKey += locToStr(posVal.a); // grouped paths
			lastVal = posVal;
		}
		if(locsKey in tempMap) {
			mapOfLinesCode = tempMap[locsKey]; // get current list
			mapOfLinesCode += ([lastVal.b..lastVal.c+1] : aggDupKey);
			tempMap = delete(tempMap, locsKey);
			tempMap += (locsKey : mapOfLinesCode);
		}
		else {
			mapOfLinesCode += ([lastVal.b..lastVal.c+1] : aggDupKey);
			tempMap += (locsKey : mapOfLinesCode);
		}
		locsKey = "";
	}
	
	//println(tempMap);
	list[list[int]] toDelete = [];
	list[int] l = [];
	for(groupKey <- tempMap) {
		groupVal = tempMap[groupKey]; // key=lines val=codeline
		// check who is the superset. and make list of subsets to remove
		for(linesList <- groupVal) {
			if(linesList >= l) {
				toDelete += [l];
				l = linesList;
				//println("true: <linesList> \>= <l>");
			}
			else {
				//println("false: <linesList> \>= <l>");
				toDelete += [linesList];
			}
		}
		// remove all listed subsets
		for(delKey <- toDelete) {
			if(isEmpty(delKey))
				continue;
			codeLineToDel = groupVal[delKey];
			//println(codeLineToDel);
			duplicates = delete(duplicates, codeLineToDel);
		}
		
		//println("toDel: <toDelete>");
		//println("---");
		toDelete = [];
		l = [];
	}
	
	//println(now()-timer);
	//println("===\n\rdone. Total time: <now()-totaltime>");
	
	//return duplicates;
	return duplicates;
}

public tuple[str, list[tuple[loc, int, int]]] expandDupBlocksSmall(tuple[str Code, tuple[tuple[loc fileLoc, int fromLine, int toLine] A, tuple[loc fileLoc, int fromLine, int toLine] B] Pos] duplicates, map[loc, list[str]] filesWithDups) {
	tuple[str, list[tuple[loc a, int b, int c]]] expandedDups;

	str tempLineA = "";
	str tempLineB = "";
	int nextlineA = 0;
	int nextlineB = 0;
	int lineSucc = 1;
	list[tuple[loc a, int b, int c]] tempList = [];

	list[str] tempCodeA = filesWithDups[duplicates.Pos.A.fileLoc];
	list[str] tempCodeB = filesWithDups[duplicates.Pos.B.fileLoc];
	
	if(tempCodeA[duplicates.Pos.A.toLine] != tempCodeB[duplicates.Pos.B.toLine]) // just verification control / debugging. must be equal.
		throw "Error occured!";

	tempBlock = duplicates.Code;
	lineSucc = 1;
	while(true) {  // lets check if also next lines are equal (out of block size)
		nextlineA = duplicates.Pos.A.toLine+lineSucc;
		nextlineB = duplicates.Pos.B.toLine+lineSucc;
		//println("<size(tempCodeA)> \< <nextlineA>");
		if(size(tempCodeA)-1 < nextlineA || size(tempCodeB)-1 < nextlineB) // if no more code lines
			break;
		tempLineA = tempCodeA[nextlineA]; // last line of duplicated code identified + 1
		tempLineB = tempCodeB[nextlineB];

		if(tempLineA != tempLineB)
			break;
			
		tempBlock += tempLineA;	// A & B are the same. doesn't matter who we add

		lineSucc += 1;
	}
	
	
	// insert to aggregated duplicates map
	tempList += <duplicates.Pos.A.fileLoc, duplicates.Pos.A.fromLine, nextlineA-1>;
	tempList += <duplicates.Pos.B.fileLoc, duplicates.Pos.B.fromLine, nextlineB-1>;
	expandedDups = <tempBlock , tempList>;

	return expandedDups;
}

public bool inBetween(int n, int min, int max, bool inclusive) {
	if(n < max && n > min)
		return true;
	if(inclusive && n <= max && n >= min)
		return true;
	return false;
}

public list[tuple[&T, &T]] listPairs(list[&T] tlist) {
	int listSize = size(tlist);
	if(listSize <= 1)
		return [];
	list[tuple[&T, &T]] pairs = [];
	// Total size: Triangular number (n * (n+1)) / 2 
	for(i <- [0..listSize]) {
		for(n <- [i..listSize]) {
			if(i != n)
				pairs += <tlist[i], tlist[n]>;
		}
	}
	return pairs;
}
