module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;
import Map;
import Set;

public map[tuple[int, int], str] CreateBlocks(loc path, int blockSize) {
	list[str] code = CleanCode(path);
	map[tuple[int, int], str] blocks = ();
	str tempBlock = "";
	int lineIndex = 0;
	int codeSize = size(code);
	
	for(line <- code) {
		// create blocks
		for(i <- [0..blockSize]) {
			if(i+lineIndex < codeSize)
				tempBlock += code[i+lineIndex];
		}
		blocks += (<lineIndex, lineIndex+blockSize> : tempBlock);
		tempBlock = "";
		lineIndex += 1;
	}
	return blocks;
}

//public map[str, tuple[int, int]] FindDuplicates(map[str, tuple[int, int]] blocks) {
public map[tuple[int, int], str] FindDuplicates(map[tuple[int, int], str] blocks) {
	//list[str] blocksList = [blocks[v] | _:v <- blocks];
	map[tuple[int, int], str] duplicates = ();
	int blockIndex = 0;
	
	for(k <- [ k | k <- blocks], v <- [ blocks[v] | v <- blocks]) {
		//println("k = <k> \n\r\n\r");
		map[tuple[int, int], str] searchStack = delete(blocks, k);
		//println("v2 = <searchStack>\n\r\n\r");
		for(vStack <- [ searchStack[vStack] | vStack <- searchStack]) {
			//println("<vStack> =? <v>\n\r");
			if(vStack == v)
				duplicates += (k:v);
		}
		blockIndex += 1;
	}
	return duplicates;
	
	//int countOrg = size(blocksList);
	//list[str] blocksListNew = dup(blocksList);
	//int countNew = size(blocksListNew);
	//return (countOrg - countNew);
}

// public map[str, tuple[int, int]] FindDuplicates(loc path, int size) {
//public tuple[str, int] FindDuplicates(loc path, int dupSize) {
//public str FindDuplicates(loc path, int dupSize) {
//	list[str] code = CleanCode(path);
//	int lineIndex = 0;
//	//map[str, int] x = [];
//	list[str] tempBlocks = [];
//	for(line <- code) {
//		for(i <- [0..dupSize]) {
//			if(i+lineIndex <= size(code))
//				tempBlock += code[i+lineIndex];
//		}
//		code = delete(code, lineIndex);
//		
//	}
//}

//public int FindLines(list[str] block, list[str] code) {
//	int lineNumber = 0;
//	for(codeLine <- code) {
//		for(line <- block) {
//			if(codeLine == line) {
//				FindLines
//			}
//			lineNumber += 1;
//		}
//	}
//	return -1;
//}


// |project://Hello/src/testPack/Main.java|
public list[str] GroupBlocks(loc path, int size) {
	list[str] lines = readFileLines(path);
	list[str] blocks = [];
	str tempBlock = "";
	int counter = 0;
	
	for(line <- lines) {
		tempBlock += line;
		counter += 1;
		// Group lines to defined block size
		if(counter >= size) {
			// add the block, reset temp vars
			blocks += tempBlock;
			counter = 0;
			tempBlock = "";
		}
	}
	if(counter > 0)
		blocks += tempBlock; // add the rest of the code to a new block
	return blocks;
}