module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import Map;
import Set;

public map[str, list[tuple[loc, int, int]]] DuplicatesAnalyzer(loc dirPath, str fileExt, int blockSize) {
	list[loc] files = getFiles(dirPath, fileExt);
	map[str, list[tuple[loc, int, int]]] blocks = ();
	map[str, list[tuple[loc, int, int]]] duplicates = ();
	
	for(filePath <- files) {
		list[str] code = CleanCode(filePath);
		str tempBlock = "";
		list[tuple[loc, int, int]] tempList = [];
		
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
			
			if(tempBlock notin blocks)
				blocks += (tempBlock: [<filePath, lineIndex, lineIndex+blockSize>]);
			else { // if is duplicate, add his location / update key
				tempList =  blocks[tempBlock];
				tempList += <filePath, lineIndex, lineIndex+blockSize>;
				if(tempBlock in duplicates)
					duplicates = delete(duplicates, tempBlock);
				duplicates += (tempBlock: tempList);
			}
			tempBlock = "";
			tempList = [];
			lineIndex += 1;
		}
	}
	return duplicates;
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
