module AST::Group

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;

public list[tuple[node,int]] GroupTrees2(list[tuple[node,int]] subtrees, int t)  = subtrees;

// Since single statements will normally not be grouped together (only in block statements) so we have to do it manually
public list[tuple[node,int]] GroupTrees(list[tuple[node,int]] subtrees, int t) 
{
	list[tuple[node,int]] newList = [];
	list[tuple[node,int]] statements = [];
	for (tuple[node a,int b] l <- subtrees) {
		switch(l.a) {
			case \block(b)	: 	
			{ 
				//newList += MakeBlocks(statements, t); 
				newList += Sublists(statements, t);
				if (l.b >= t)
					newList += l;
				statements = [];
			}
			default 		:	statements += l;
		}
	}
	return newList;
}

public list[tuple[node,int]] MakeBlocks(list[tuple[node,int]] statements, int t)
{
	newList = [];
	int s = 0;		// Size of the block
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (tuple[node a, int b] i <- statements) {
		switch(i.a) {
			case Statement x:	
			{
				tempList = [];
				int q = 0;
				while (q + c < boundary) {
					tuple[node a, int b] newTup = statements[c + q]; 
					s += newTup.b;
					tempList += newTup;
					q += 1;
				}
				if (s >= t) {
					newList += MakeBlock(tempList);
				}
			}
		}
		c += 1;
		s = 0;
	}
	return newList;
}

public tuple[node, int] MakeBlock(list[tuple[node,int]] statements)
{
	list[Statement] newStatements = [];
	int s = 0;
	int length = 0;
	int endLine = 0;
	int endColumn = 0;
	
	// Get location
	tuple[node a ,int b] first = statements[0];
	loc location;
	loc last;
	switch(first.a) {
		case Statement b : { location = b@src; last = b@src;}
	}
	for (tuple[node a, int b] i <- statements) {
		switch(i.a) {
			case Statement b :
			{
				s += i.b;
				newStatements += b;
				endLine = b@src.end.line;
				endColumn = b@src.end.column;
				last = b@src;
			}
		}
	}
	length = last.offset - location.offset + last.length;
	// Create new tuple
	Statement statement = \block(newStatements);
	statement@src = location(location.offset,length,<location.begin.line,location.begin.column>,<endLine,endColumn>);
	return <statement, s>;
}

// Get all sublists with at least size t
private list[tuple[node,int]] Sublists(list[tuple[node, int]] l, int t)
{
	lists = [];
	for (i <- [0..size(l)]) {
		sub = [];
		s = 0;
		for (j <- [i..size(l)]) {
			tuple[node a, int b] tup = l[i];
			switch(tup.a) {
				case Statement b : 
				{
					sub += l[j];
					s += tup.b;
					if (s >= t)
						lists += MakeBlock(sub);
				}
			}
		}
	}
	return lists;
}