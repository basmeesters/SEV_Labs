module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;
import IO;

public map[str, tuple[int, int]] FindDuplicates(loc path, int size) {
	list[str] blocks = GroupBlocks(path, size);
	if(size(blocks) == 0)
		return false;
	
}
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