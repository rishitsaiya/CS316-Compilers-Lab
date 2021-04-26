/* Acknowledgements: 
1. Github links referres to --> (Some repos are in Java still it helped me to understand the logic)
								a. https://github.com/abahrain/ECE-468
								b. https://github.com/maheshbabugorantla/Fall_2017_Compilers
								c. https://github.com/laizixian/ECE468/tree/master/468project-chickendinner-final
								d. https://github.com/dooly107/Introduction-to-Compilers
2. Me (180010027) --> Discussed logics and debugging with below classmates
3. Balsher Sharma (180010008) --> Debugging help
4. Karan Sharma (180010019) --> code and solving bugs
*/

// Import libraries
#include <stdio.h>
#include <stdlib.h>
#include <list>
#include <map>
#include <utility>
#include <algorithm>
// Import from headers/
#include "headers/symbol.h"
#include "headers/vision.h"
#include "headers/nodeAST.h"
#include "headers/codeOptimizer.h"

// Creating Symbol Table, a vector of elements of Vision class
extern std::vector<std::vision*> SymTabHead;
// Creating IR_vector, a vector of elements of IR_code Class
extern std::vector<std::IR_code*> IR_vector;
