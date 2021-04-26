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

// Import Libraries and headers
#ifndef SCOPE_H
#define SCOPE_H
#include <string>
#include <utility>
#include <algorithm>
#include <map>
#include <vector>
#include "symbol.h"


namespace std{
	class vision // Class for vision
	{
		private:
			string name; // String for name of scope
			std::map< string, symbol*> ScopeTab; // Mapping for Scope tab
		 	std::vector<std::string> err_checker; // Vector for error checker defined
		public:
			vision(string name_v); // vision function
			virtual ~vision(); 
			string get_name(); // string get_name defined
			std::map< string, symbol*> get_tab(); // Mapping for get_tab defined
			void insert_record(string , symbol*); // Function for insert_record added
	};
}
#endif
