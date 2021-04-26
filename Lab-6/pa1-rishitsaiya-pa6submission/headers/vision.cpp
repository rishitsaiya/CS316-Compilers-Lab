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

// Import headers and libraries
#include "vision.h"
#include <iostream>

namespace std{
	vision::vision(string name_v){ // Class for vision
		name = name_v; 
		static std::vector<std::string> newVector; // newVector created
		err_checker = newVector;
		static std::map< string, symbol*> newMap;
		ScopeTab = newMap;
	}
	vision::~vision(){
	}

	string vision::get_name(){ // Function to get name in vision calss
		return name;
	}
	std::map< string, symbol*> vision::get_tab(){ // Function to get_tab from the mapping
		return ScopeTab;
	}
	void vision::insert_record(string key_name, symbol* symRecord){ // Function to insert record in activation record
		string sym_name = *(symRecord -> get_name()); // Get the name from symbol activation record
		if (std::find(err_checker.begin(), err_checker.end(), sym_name ) != err_checker.end()){ // If error checker at the start is not same as at the end
			cout << "DECLARATION ERROR " << sym_name << "\r\n"; // Declare error
			exit(1);
		}
		ScopeTab[key_name] = symRecord; // Assign that symbol record to the scopetab array
		err_checker.push_back(*(symRecord -> get_name())); // add this record to err_checker stack
	}
}
