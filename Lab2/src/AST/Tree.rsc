module AST::Tree

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import Node;
import List;
import Map;
import util::Math;
import AST::Group;
import DateTime;

// The project locations
public loc simple = |project://Hello|;
public loc small = |project://smallsql0.21_src|;
public loc big = |project://hsqldb-2.3.1|;

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// Print the found duplicates
public void PrintTrees(loc project, int t)
{
	time = now();
	int sm =0;
	ast = AST(project);
	map[node,list[node]] trees = Subclones(FilterClones(MethodTrees(ast, t)));
	int i =0;
	for(node a <- trees) {
		i += 1;
		top-down-break visit(trees[a]) {
			case Statement b 	: 	
			{
				println("<i> : <b@src>");
				sm += (b@src.end.line - b@src.begin.line + 1);
			}
		}
	}
	println(sm);
	println(createDuration(time, now()));
}

// Get all the subtrees given a node 
public list[tuple[node,int]] Subtrees(node a, int t) = [<n,s> | /node n <- a, s <- [SizeTree(n)], s >= t];
private int SizeTree(node n) = (0|it+1|/node _ <-n);

// Get all subtrees within methods / constructors
private map[node,list[node]] MethodTrees(set[Declaration] ast, int t)
{
	map[node,list[node]] dict = ();
	top-down visit(ast) {
		case a:\constructor(n, p, e, s)	:	dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
		case a:\method(r,n, p, e, s) 	:	dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
		case a:\method(t,n, p, e)  		:	dict += Hash(dict, GroupTrees(Subtrees(a,0), t), t);
	}
	return dict;
}

// Create map and hash the subtrees
private map[node, list[node]] Hash (map[node, list[node]] dict, list[tuple[node,int]] trees, int t)
{
	for (tuple[node a,int b] l <- trees) {
		switch(l.a) {
			case Statement n : 
			{
				bool temp = false;
				if (n in dict) {
					for (j <- dict[n]) {
						Statement i;
						switch(j) { case Statement b : i = b; }
						if (abs(i@src.begin.line - n@src.begin.line) <= 1) {
							temp = true;
							break;
						}
					}
					if (temp == false && l.b >= t) {
						dict += (n : dict[n] + n);
					}
				}
				else
					dict += (n : [n]);
			}
		}
	}
	return dict;
}

// Filter out only subtrees with multiple instances (clones)
private map[node,list[node]] FilterClones(map[node,list[node]] trees)
{
	dict = ();
	for(node a <- trees) {
		s = size(trees[a]);
			if (s > 1) {
				dict += (a: trees[a]);
			}
	}
	return dict;
}

public map[node,list[node]] Subclones(map[node,list[node]] trees)
{
	dict = ();
	for (tree <- trees) {
		switch(tree) {
			case \block(bl)	: 	
			{
				bool clone = false;
				bool clone2 = false;
				node temp;
				for (key <- dict) {
					switch(key) {
						case \block(k) :
						{
							if (bl <= k || /tree := key) {
								clone = true;
							}
							else if(k <= bl || /key := tree) {
								clone2 = true;
								temp = key;
							}
						}
					}
				}
				if (clone) ;
				else if(clone2) {
					dict = delete(dict, temp);
					dict += (tree : trees[tree]);
				}
				else
					dict += (tree : trees[tree]);
			}
		}
	}
	return dict;
}