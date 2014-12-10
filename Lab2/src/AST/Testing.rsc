module AST::Testing

import IO;
import AST::Tree;
import AST::Serializing;

// Test Tree
public void AllStatements(loc project)
{
	ast = AST(project);
	s = 0;
	 visit(ast) {
		case Statement _			:	s += 1;
	}
	println(s);
}

// Test Sequences

// Test Serializing
