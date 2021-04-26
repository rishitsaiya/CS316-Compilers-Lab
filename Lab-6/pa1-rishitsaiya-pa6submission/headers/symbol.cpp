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

// Import headers
#include "symbol.h"

namespace std{
	symbol::symbol(string* name_v, string* value_v, int type_t, int stack_p){ // Class for symbols
		name = name_v; // Name of symbol
		value_s = value_v; // Value of symbol
		type = type_t; // Type of Symbol
		stack_pointer = stack_p; // Stack Pointer in AR
	}
	symbol::~symbol(){ // Function for symbol

	}

	string * symbol::get_name(){ // Function for symbol class to get name of symbol
		return name;
	}
	string * symbol::get_value(){ // Function for symbol class to get value of symbol
		return value_s;
	}
	int symbol::get_type(){ // Function for symbol class to get type of symbol
		return type;
	}
	int symbol::get_stack_pointer(){ // Function for symbol class to get stack pointer
		return stack_pointer;
	}
}
