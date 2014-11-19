module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import Map;
import Set;
import Exception;

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

public map[str, list[tuple[loc, int, int]]] DuplicatesAnalyzer(loc dirPath, str fileExt, int blockSize) {
	if(blockSize < 1)
		throw "blockSize must be greater than zero!";
	list[loc] files = getFiles(dirPath, fileExt);
	map[str, list[tuple[loc, int, int]]] blocks = ();
	map[str, list[tuple[loc a, int b, int c]]] duplicates = ();
	
	for(filePath <- files) {
		list[str] code = CleanCode(filePath);
		str tempBlock = "";
		list[tuple[loc, int, int]] tempList = [];
		
		int lineIndex = 0;
		int codeSize = size(code);
		int lastI = 0;
		bool isBreak = false;
	
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
			
			if(tempBlock notin blocks)
				blocks += (tempBlock: [<filePath, lineIndex, lineIndex+lastI-1>]);
			else { // if is duplicate, add his location / update key				
				tempList = blocks[tempBlock];
				tempList += <filePath, lineIndex, lineIndex+lastI-1>;
				if(tempBlock in duplicates)
					duplicates = delete(duplicates, tempBlock);
				duplicates += (tempBlock: tempList);
			}
			tempBlock = "";
			tempList = [];
			lineIndex += 1;
		}
	}
	
	
	// create all location pairs possibilities of duplicate for comparison
	// 1,2,3 = 1:2 , 1:3 , 2:3
	list[tuple[tuple[loc a1, int a2, int a3] A, tuple[loc b1, int b2, int b3] B]] dupsPairs = [];
	map[str, list[tuple[loc a, int b, int c]]] aggDups = ();
	list[str] tempCodeA = [];
	list[str] tempCodeB = [];
	str tempLineA = "";
	str tempLineB = "";
	int nextlineA = 0;
	int nextlineB = 0;
	int lineSucc = 1;
	for(dupKey <- duplicates) {
		dupValues = duplicates[dupKey]; // single duplicate
		//println(dupValues);
		dupsPairs = listPairs(dupValues);
		for(pair <- dupsPairs) {
			tempCodeA = CleanCode(pair.A.a1);
			if(pair.A.a1 == pair.B.b1) // save some time if it is the same file
				tempCodeB = tempCodeA;
			else
				tempCodeB = CleanCode(pair.B.b1);
			if(tempCodeA[pair.A.a3] != tempCodeB[pair.B.b3]) // just verification control / debugging. must be equal.
				throw "Error occured!";

			tempBlock = dupKey;
			lineSucc = 1;
			while(true) {  // lets check if also next lines are equal (out of block size)
				nextlineA = pair.A.a3+lineSucc;
				nextlineB = pair.B.b3+lineSucc;
				if(size(tempCodeA) < nextlineA || size(tempCodeB) < nextlineB) // if no more code lines
					break;
				tempLineA = tempCodeA[nextlineA]; // last line of duplicated code identified + 1
				tempLineB = tempCodeB[nextlineB];
				//println("<pair.A.a3> : <tempLineA> ?= <pair.B.b3> : <tempLineB>");
				if(tempLineA != tempLineB)
					break;
					
				tempBlock += tempLineA;	// A & B are the same. doesn't matter who we add
				
				// println("<pair.A.a2> - <pair.A.a3+lineSucc> : <pair.B.b2> - <pair.B.b3+lineSucc>");
				lineSucc += 1;
			}
			
			tempList = [];
			if(tempBlock in aggDups) {
				// get previous aggregated duplicates from map
				tempList = aggDups[tempBlock];
				aggDups = delete(aggDups, tempBlock);
			}
			// insert to aggregated duplicates map
			tempList += <pair.A.a1, pair.A.a2, nextlineA-1>;
			tempList += <pair.B.b1, pair.B.b2, nextlineB-1>;
			aggDups += (tempBlock : tempList);
			
			println("<pair.A.a2> - <pair.A.a3+lineSucc> : <pair.B.b2> - <pair.B.b3+lineSucc>");
			// reset params
			tempList = [];
			tempBlock = "";
		}
		
		//println(dupsPairs);
	}
		
/*			
	// Bas's bug report
	// if duplication lines is more than blockSize	
	// test duplicated block expandability
	// it is known that next block on the list is also the same line
	map[str, list[tuple[loc a, int b, int c]]] aggDups = ();
	bool isLineMatch = true;
	list[str] tempCode = [];
	str tempBlock = "";
	// blocksLocKey = invert(blocks); // use filePath/lines as key
	for(dupKey <- duplicates) {
		dupValues = duplicates[dupKey];
		for(dupVal <- dupValues){
			dupFilePath = dupVal.a;
			dupFromLine = dupVal.b;
			dupToLine = dupVal.c;
			tempCode = CleanCode(t_filePath); // get code
			tempBlock += dupVal;
			while(isLineMatch) {
				tempBlock += tempCode[dupToLine+1];
			}
			
		}
		while(isLineMatch) {
			;
		}
		// duplicate can be repeated more than twice
		// duplicates += (tempBlock: [<filePath, lineIndex, lineIndex+blockSize>]);
	}
*/
	//return duplicates;
	return aggDups;
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


/*
* OLD FUNCTIONS - not relevant for the above
*/

//public map[str, map[tuple[int, int], str]] LocDuplicates(loc dirPath, int blockSize) {
public map[tuple[loc, int, int], str] LocDuplicates(loc dirPath, int blockSize) {
	list[loc] files = getFiles(dirPath, "java");
	map[tuple[loc, int, int], str] blocks = ();
	for(file <- files)
		blocks += CreateBlocks(file, blockSize);
	//println(blocks);
	//return ();
	return FindDuplicates(blocks);
}

public int LocDuplicatesCount(loc dirPath, int blockSize) {
	list[loc] files = getFiles(dirPath, "java");
	map[tuple[loc, int, int], str] blocks = ();
	for(file <- files)
		blocks += CreateBlocks(file, blockSize);
	return CountDuplicates(blocks);
}

public map[tuple[loc, int, int], str] CreateBlocks(loc filePath, int blockSize) {
	list[str] code = CleanCode(filePath);
	map[tuple[loc, int, int], str] blocks = ();
	str tempBlock = "";
	int lineIndex = 0;
	int codeSize = size(code);
	bool isBreak = false;

	for(line <- code) {
		// create blocks
		for(i <- [0..blockSize]) {
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
		blocks += (<filePath, lineIndex, lineIndex+blockSize> : tempBlock);
		tempBlock = "";
		lineIndex += 1;
	}
	return blocks;
}

public int CountDuplicates(map[tuple[loc, int, int], str] blocks) {
	list[str] blocksList = [blocks[v] | v <- blocks];
	int sizeOrg = size(blocksList);
	int sizeFiltered = size(dup(blocksList));
	return (sizeOrg-sizeFiltered);
}

public map[tuple[loc, int, int], str] FindDuplicates(map[tuple[loc, int, int], str] blocks) {
	map[tuple[loc, int, int], str] duplicates = ();
	int blockIndex = 0;
	
	for(k <- blocks) {
		v = blocks[k];
		blocks = delete(blocks, k);
		//println("k: <k>");
		for(kStack <- blocks) { 
			vStack = blocks[kStack];
			if(vStack == v) {
				duplicates += (k:v);
				duplicates += (kStack:vStack);
				//println("kStack: <kStack>");
				//blocks = delete(blocks, kStack);
			}
		}
		blockIndex += 1;
	}
	return duplicates;
}
