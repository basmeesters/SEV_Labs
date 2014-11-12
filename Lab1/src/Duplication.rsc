module Duplication

import CodeLines;
import FilesHandling;
import String;
import List;

public map[str, tuple[int, int]] FindDuplicates(loc path, int size) {
	list[str] blocks = GroupBlocks(path, size);
	if(size(blocks) == 0)
		return false;
	
}

public list[str] GroupBlocks(loc path, int size) {
	list[str] lines = readFileLines(path);
	list[str] blocks = [];
	str tempBlock = "";
	int counter = 0;
	
	for(line <- lines) {
		tempBlock += line;
		// Group lines to defined block size
		if(counter >= size) {
			// add the block, reset temp vars
			blocks += line;
			counter = 0;
			tempBlock = "";
		}
	}
	if(counter > 0)
		blocks += line; // add the rest of the code to a new block
	return blocks;
}