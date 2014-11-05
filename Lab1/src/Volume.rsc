module Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import IO;
import ParseTree;

// Model of the class
public loc project = |project://Hello|;
public M3 model = createM3FromEclipseProject(project);
public set[Declaration] decls = createAstsFromEclipseProject(project,true);

list[str] program = readFile(|project://Hello/src/testPack/Main.java|);

public set[loc] containMain() {return model@containment[|java+class:///testPack/Main|]; }
public rel[loc from, loc to] contain = model@containment;

public int linesOfCode(list[str] program) 
{
	int count = 0;
	for(/[\n]+/ := S){
	   count += 1;
  }
}

public Declaration methodAST = getMethodASTEclipse(|java+method:///testPack/Main/main(java.lang.String%5B%5D)|, model=model);
public int exprCount(Declaration d) {return (0 | it + 1 | /Expression _ := d); }
// set[loc] contain() {return myModel@containment[|java+class:///Main|]; }
// list[loc] methods() {return [ e | e <- myModel@containment[|java+class:///Main|], e.scheme == "java+method"];; }

public list[loc] locations = [m@src | /Expression m := methodAST];

// Extract information
public list[loc] classes = [ e | e <- model@containment[|java+package:///testPack|]];
public list[loc] methods = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+method"];
public list[loc] fields = [ e | e <- model@containment[|java+class:///testPack/Main|], e.scheme == "java+field"];

// methods of the whole package
//public list[loc] methods2 = methods(model);
