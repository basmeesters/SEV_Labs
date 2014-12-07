module DuplicationBas

import LOC;
import DateTime;
import List;
import IO;

public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

alias duplicateBlocks = map[list[str], list[tuple[loc, int, int]]];

public duplicateBlocks CreateBlocks(loc project, int s)
{
	map[loc, list[str]] l = LinesPerUnit(project);
	return CreateBlocks(l, s);
}

public duplicateBlocks CreateBlocks(map[loc,list[str]] codeUnits, int b)
{
	map[list[str], tuple[loc,int,int]] blocks = ();
	duplicateBlocks duplicates = ();
	for (l <- codeUnits) {
		list[str] code = codeUnits[l];
		int s = size(code); 
			
		// Location values
		int startrow = l.begin.line;
		int startcolumn = l.begin.column;
		int endrow = l.end.line;
		int endcolumn = l.end.column;
		int offset = l.offset;
		int length = l.length;
		
		for (i <- [0..s]) {
			
			int end = i + b; 
			if (s >= end) {
				block = code[i..end];
				l = l(offset,length,<startrow,startcolumn>,<endrow + 5,endcolumn>);
				tup = <l, startrow + i, startrow + i + 5>;
				if (block in blocks) {
					list[tuple[loc lo, int a, int b]] dup;
					if (block in duplicates) {
						dup = duplicates[block] + tup;
					} else {
						dup = [blocks[block]] + tup;
					} duplicates += (block : dup);
				}
				else
					blocks += (block : tup);
			}
			else
				break;
			
		}
	}
	return duplicates;
}
public void ExtendBlocks(loc project)
{
	return ExtendBlocks(CreateBlocks(project, 6));
}

public void ExtendBlocks(duplicateBlocks duplicates)
{
	newDup = ();
	for (codeUnits <- duplicates) {
		loc original = |project://empty|;
		for (location <- duplicates[codeUnits]) {
			if (original == |project://empty|) {
				location = original;
			}
			else {
				; 
			}
		}
	}
}

// Return the amount of duplicated lines
public int CountAmount(loc project,int b)
{
	int s = 0;
	c = CreateBlocks(project, b);
	for (key <- c) {
		for (l <- [0..size(c[key]) -1]) {
			s += size(key);
		}
	}
	return s;
}
