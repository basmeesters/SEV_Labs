module Complexity

import analysis::graphs::Graph;

public int cyclomaticComplexity(Graph[&T] PRED){
 return size(PRED) - size(carrier(PRED)) + 2;
}

// BTW, The "uses" and "declarations" relations together can be combined to get a graph that links uses to definition sites, i.e. `m@uses o m@declarations`.