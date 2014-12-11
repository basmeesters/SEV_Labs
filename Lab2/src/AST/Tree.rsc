module AST::Tree

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Map;
import Set;

alias duplicationMap = map[list[Statement], rel[loc,list[Statement],int]];

// Just a shorter variant 
public set[Declaration] AST(loc project) = createAstsFromEclipseProject(project,true);

// Get all subtrees within methods / constructors
public list[list[Statement]] MethodStatements(set[Declaration] ast, int t)
{
	statements = [];
	top-down-break visit(ast) {
		case a:\initializer(s)			:	statements += MakeBlocks(GetStatements([s]), t);
		case a:\constructor(n, p, e, s)	:	statements += MakeBlocks(GetStatements([s]), t); 
		case a:\method(r,n, p, e, s) 	:	statements += MakeBlocks(GetStatements([s]), t); 
	}	
	// 		LOC += (a@src.end.line - a@src.begin.line);	
	return statements;
}

// Get all statements in a particular method or block of statements (recursively)
public list[Statement] GetStatements(list[Statement] method)
{
	list[Statement] statements = [];
	Statement em = \block([]);
	for (s <- method) {
		//statements += s; 
		switch(s) {
			case \block(b) 						:	
				statements += GetStatements(b); 
			case m:\do(b,a)						: 	
				{m2 = \do(em,a); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
			case m:\foreach(a,a2,b)				:	
				{m2 = \foreach(a,a2,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); } 
			case m:\for(a,a2,a3,b)				:	
				{m2 = \for(a,a2,a3,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
			case m:\for(a,a2,b)					:	
				{m2 = \for(a,a2,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); } 
			case m:\if(a,b)						:   
				{m2 = \if(a,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
    		case m:\if(a,b, b2)					:  
    			 {m2 = \if(a,em, em); m2@src = m@src; statements += m2; statements += GetStatements([b]); statements += GetStatements([b2]); }
    		case m:\label(a,b)					:   
    			{m2 = \label(a,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); }  
			case m:\switch(a,b)					:	
				{m2 = \switch(a,[]); m2@src = m@src; statements += m2; statements += GetStatements(b); }
			case m:\synchronizedStatement(a,b) 	:	
				{m2 = \synchronizedStatement(a,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); } 
			case m:\try(b,e)					:	
				{m2 = \try(em,e); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
			case m:\try(b,e,f)					:	
				{m2 = \try(em,e,em); m2@src = m@src; statements += m2; statements += GetStatements([b]);statements += GetStatements([f]);} 
			case m:\catch(a,b)					:	
				{m2 = \catch(a,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
			case m:\while(a,b)					:	
				{m2 = \while(a,em); m2@src = m@src; statements += m2; statements += GetStatements([b]); }
			default 							:	
				statements += s;					
		}
	}
	return statements;
}

// Create sublists of the lists of statements bigger than the threshold t
public list[list[Statement]] MakeBlocks(list[Statement] statements, int t)
{
	newDict = [];
	int c = 0;		// Counter for statements
	boundary = size(statements);
	for (Statement x <- statements) {
		tempList = [];
		int q = 0;
		while (q + c < boundary) {
			Statement newTup = statements[c + q]; 
			tempList += newTup;
			if(q + 1>= t)
				newDict += [tempList]; 
			q += 1;
		}
		c += 1;
	}
	return newDict;
}

// Create a tuple of location, code and size of the code for a list of statements
public tuple[loc, list[Statement], int] MakeBlock(list[Statement] statements)
{
	int endLine = 0;
	int endColumn = 0;
	newStatements = [];
	Statement first = statements[0];
	loc location = statements[0]@src;
	int startLine = location.begin.line;
	int lastPosition = 0;
	loc lastStatement = last(statements)@src;

	endLine = lastStatement.end.line;
	endColumn = lastStatement.end.column;
	length = lastStatement.offset - location.offset + lastStatement.length;
	newLocation = location(location.offset,length,<location.begin.line,location.begin.column>,<endLine,endColumn>);
	return <newLocation, statements, endLine - startLine + 1>;
}

// Hash the statements to a map and filter out all keys with value sizes lower than 1
public duplicationMap Hash(list[list[Statement]] statements) = toMap([<s, MakeBlock(s)>| s <- statements]);
public duplicationMap Filter(duplicationMap m) = (r : m[r] | r <- m, size(m[r]) > 1);
public set[loc] Locations(list[Statement] statements) = {takeOnFrom(f).uri |  list[Statement] f <- s};

public duplicationMap Subclones(duplicationMap trees)
{
	dict = ();
	for (tree <- trees) {
		bool clone = false;
		bool clone2 = false;
		node temp;
		for (key <- dict) {
			if (tree <= key) {
				clone = true;
				//for (tuple[loc a,list[Statement] b,int c] k <- trees[key]) {
				//	if (!(k.b <= key)) {
				//		clone = false;
				//		break;
				//	}
				//}
			}
			else if(key <= tree) {
				clone2 = true;
				temp = key;
				//for (tuple[loc a,list[Statement] b,int c] k <- trees[key]) {
				//	if (!(key <= k.b)) {
				//		clone2 = false;
				//		break;
				//	}
				//}
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
	return dict;
}