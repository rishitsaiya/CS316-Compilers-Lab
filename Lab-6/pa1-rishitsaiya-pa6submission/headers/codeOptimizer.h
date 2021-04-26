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

// Import libraries and headers
#ifndef TINY_H
#define TINY_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include <stack>
#include <iostream>
#include "../main.h"


namespace std{
	class codeOptimizer{ // Code Optimizer Class
	private:
		std::vector<std::IR_code*> IR_vector; // IR vector
		std::map<string, string> var_dict; // Variable Dictionary to store mapping
		std::map<string, string> reg_dict; // Register Dictionary to store mapping
		std::map<string, string> act_record; // Activation Record to store mapping
		string reg_prefix; // String to store Register Prefix
		int reg_counter; // Var for register counter
		string reg_counter_str; // String for register counter value as a string
		string s; 
		size_t pos_t;
		string temp_num;
	public:
		virtual ~codeOptimizer(); // Code Optimizer 
		codeOptimizer(std::vector<std::IR_code*> IR_vector_in); // Passing IR vector to CodeOptimizer function
		void genTiny(); //calling generate Tiny function
	};

}
#endif
