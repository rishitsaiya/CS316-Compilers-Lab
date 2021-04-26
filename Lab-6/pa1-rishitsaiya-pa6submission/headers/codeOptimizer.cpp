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

// Include header files
#include "codeOptimizer.h"

// Define customized namespace function for codeOptimizer.cpp
namespace std{
	codeOptimizer::codeOptimizer(std::vector<std::IR_code*> IR_vector_in){
		IR_vector = IR_vector_in;
		reg_counter = -1;
		reg_counter_str = "";
		s = "";
	}

// Code Optimizer Function declared
	codeOptimizer::~codeOptimizer(){}

// Generating Tiny Function declared
	void codeOptimizer::genTiny(){
		int regcnt = 0; // Register Counter added
		int curr_reg; // Current Register var
		std::string cmpr_val; // String comparison value
		std::stack<int> reg_stack; // Register Stack initiated
		std::stack<int> IR_ct_stack; // IR counter stack initiated
		std::stack<std::string> label_stack; // Label Stack initiated
		for (int i = 0; i < IR_vector.size(); i++) {
			// If operation type is either of STOREI or STOREF
			if (IR_vector[i]->get_op_type() == "STOREI" ||
				IR_vector[i]->get_op_type() == "STOREF"){
					// If IR vector doesn't give '!T' in result -> fetch operand 1
					if((IR_vector[i]->get_result()).find("!T") == std::string::npos){
						if (var_dict.find(IR_vector[i]->get_result()) != var_dict.end()){
							if((IR_vector[i]->get_op1()).find("!T") != std::string::npos){
								reg_dict[IR_vector[i]->get_op1()] = IR_vector[i]->get_result();
							}
						}
						// Else operand 1 in other cases
						else{
						   var_dict[IR_vector[i]->get_result()] = IR_vector[i]->get_result();
						   if((IR_vector[i]->get_op1()).find("!T") != std::string::npos){
						   	   reg_dict[IR_vector[i]->get_op1()] = IR_vector[i]->get_result();
						   }
						}
					}
				}
			
			// If operation type is either of READI or READF
			else if (IR_vector[i]->get_op_type() == "READI" ||
				IR_vector[i]->get_op_type() == "READF") {
					// If IR vector doesn't give '!T' in result -> fetch result
					if((IR_vector[i]->get_result()).find("!T") == std::string::npos){
						if (var_dict.find(IR_vector[i]->get_result()) == var_dict.end()){
							var_dict[IR_vector[i]->get_result()] = IR_vector[i]->get_result();
						}
					}
				}
		}
		
		for (int i = 0; i < IR_vector.size(); i++){
			
			// Assign current 3 Address Code from IR stack/vector
			std::IR_code* curr3ac = IR_vector[i];
			// Obtain the Operand type
			string curr_op_type = IR_vector[i] -> get_op_type();

			// For int declaration
			if( curr_op_type == "INT_DECL"){cout << "var " << IR_vector[i] -> get_op1() << endl;}
			// For float declaration
			if( curr_op_type == "FLOAT_DECL"){cout << "var " << IR_vector[i] -> get_op1() << endl;}
			// For string declaration
			if( curr_op_type == "STRING_DECL"){
				cout << "str " << IR_vector[i] -> get_op1() << " " << IR_vector[i] -> get_result() << endl;
			}
			
			// If operation type is add integers
			else if( curr_op_type == "ADDI"){ 
				cout << "move " << curr3ac->get_op2() << " r0" << endl; // Fetch value from register
				cout << "addi " << curr3ac->get_op1() << " r0" << endl; // Perform add operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is subtract integers
			else if( curr_op_type == "SUBI"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl; // Fetch value from register
				cout << "subi " << curr3ac->get_op2() << " r0" << endl; // Perform sub operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is multiply integers
			else if( curr_op_type == "MULI"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl; // Fetch value from register
				cout << "muli " << curr3ac->get_op1() << " r0" << endl; // Perform mul operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is divide integers
			else if( curr_op_type == "DIVI"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl; // Fetch value from register
				cout << "divi " << curr3ac->get_op2() << " r0" << endl; // Perform div operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is add floats
			else if( curr_op_type == "ADDF"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl; // Fetch value from register
				cout << "addr " << curr3ac->get_op1() << " r0" << endl; // Perform add operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is subtract floats
			else if( curr_op_type == "SUBF"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl; // Fetch value from register
				cout << "subr " << curr3ac->get_op2() << " r0" << endl; // Perform sub operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is multiply floats
			else if( curr_op_type == "MULF"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl; // Fetch value from register
				cout << "mulr " << curr3ac->get_op1() << " r0" << endl; // Perform mul operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is divide floats
			else if( curr_op_type == "DIVF"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl; // Fetch value from register
				cout << "divr " << curr3ac->get_op2() << " r0" << endl; // Perform div operation
				cout << "move r0 " << curr3ac->get_result() << endl; // Move back the new value
			}

			// If operation type is Label
			else if( curr_op_type == "LABEL"){
				if (curr3ac -> get_op1() == "main") {cout << "label " << curr3ac -> get_op1() << endl;} // Fetch operand 1
				else{
					cout << "label " << curr3ac -> get_result() << endl; // Else just label the result
					if (i + 1 < IR_vector.size()){ 
						if (IR_vector[i+1] -> get_op_type() == "FOR_START"){label_stack.push(curr3ac -> get_result());}
					}
				}
			}

			// If operation type is JUMP
			else if( curr_op_type == "JUMP"){
				cout << "jmp " << curr3ac->get_result() << endl; // Perform jump
			}

			// If operation type is FOR_START
			else if( curr_op_type == "FOR_START"){}

			// If operation type is FOR_END
			else if( curr_op_type == "FOR_END"){
				int temp_i = i; // Assign i to temp_i
				i = IR_ct_stack.top(); // Extract the top stack value
				IR_ct_stack.pop(); // Pop the stack
				IR_ct_stack.push(temp_i); // Push the new temp value
				
			}

			// If operation type is INCR_START
			else if( curr_op_type == "INCR_START"){
				IR_ct_stack.push(i); // Push i to the stack
				int j = i; 
				while(IR_vector[j]->get_op_type() != "INCR_END"){j++;} // Perform Increment on new counter
				i = j;
			}

			// If operation type is INCR_END
			else if( curr_op_type == "INCR_END"){
				i = IR_ct_stack.top(); // Extract the top stack value
				IR_ct_stack.pop(); // Pop the stack, basically ending increment
				cout << "jmp " << label_stack.top() << endl; // Print top of stack after ending increment
				label_stack.pop(); // Pop last element
			}

			// If operation type is GT (Greater Than)
			else if( curr_op_type == "GT"){
				// Print the operand 2
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jgt " << curr3ac->get_result() << endl;
			}
			
			// If operation type is GE (Greater Than Equal)
			else if( curr_op_type == "GE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jge " << curr3ac->get_result() << endl;
			}

			// If operation type is LT (Less Than)
			else if( curr_op_type == "LT"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jlt " << curr3ac->get_result() << endl;
			}

			// If operation type is LE (Less Than Equal)
			else if( curr_op_type == "LE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jle " << curr3ac->get_result() << endl;
			}

			// If operation type is EQ (Equal)
			else if( curr_op_type == "EQ"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jeq " << curr3ac->get_result() << endl;
			}

			// If operation type is NE (Not Equal to)
			else if( curr_op_type == "NE"){
				cout << "move " << curr3ac->get_op2() << " r0" << endl;
				// comparison operations here
				if (curr3ac->get_reg_counter() == 1){
					cout << "cmpr " << curr3ac->get_op1() << " r0" << endl;
				}
				// comparison operations here
				else if (curr3ac->get_reg_counter() == 0){
					cout << "cmpi " << curr3ac->get_op1() << " r0" << endl;
				}
				cout << "jne " << curr3ac->get_result() << endl;
			}

			// If operation type is PUSH
			else if( curr_op_type == "PUSH"){
				// If current 3 AC is empty, just print push
				if ( curr3ac->get_result().empty() ){
					cout << "push" << endl;
				}
				// Else print result of push on current 3 AC result
				else{
					cout << "push " << curr3ac->get_result() << endl;
				}
			}

			// If operation type is POP
			else if( curr_op_type == "POP"){
				// If current 3 AC is empty, just print pop
				if ( curr3ac->get_result().empty() ){
					cout << "pop" << endl;
				}
				// Else print result of pop on current 3 AC result
				else{
					cout << "pop " << curr3ac->get_result() << endl;
				}
			}

			// If operation type is PUSHREG
			else if( curr_op_type == "PUSHREG"){
				cout << "push r0\n";
			}

			// If operation type is POPREG
			else if( curr_op_type == "POPREG"){
				cout << "pop r0\n";
			}

			// If operation type is LINK
			else if( curr_op_type == "LINK"){
				cout << "link" << " " << curr3ac->get_op1() << endl;
			}

			// If operation type is UNLINK
			else if( curr_op_type == "UNLINK"){
				cout << "unlnk" << endl;
			}

			// If operation type is JSR
			else if( curr_op_type == "JSR"){
				cout << "jsr " << curr3ac->get_result() << endl;
			}

			// If operation type is RET
			else if( curr_op_type == "RET"){
				cout << "ret" << endl;
			}

			// If operation type is HALT
			else if( curr_op_type == "HALT"){
				cout << "sys halt" << endl;
			}

			// If operation type is STOREI , store integer
			else if( curr_op_type == "STOREI"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operation type is STOREF , store float
			else if( curr_op_type == "STOREF"){
				cout << "move " << curr3ac->get_op1() << " r0" << endl;
				cout << "move r0 " << curr3ac->get_result() << endl;
			}

			// If operation type is READI , read integer
			else if( curr_op_type == "READI"){
				cout << "sys readi " << IR_vector[i]->get_result() <<endl;
			}

			// If operation type is READF , read float
			else if( curr_op_type == "READF"){
				cout << "sys readr " << IR_vector[i]->get_result() <<endl;
			}

			// If operation type is WRITEI , write integer
			else if( curr_op_type == "WRITEI"){
				cout << "sys writei " << IR_vector[i]->get_op1() <<endl;
			}

			// If operation type is WRITEF , write float
			else if( curr_op_type == "WRITEF"){
				cout << "sys writer " << IR_vector[i]->get_op1() <<endl;
			}

			// If operation type is WRITES , write in system
			else if( curr_op_type == "WRITES"){
				cout << "sys writes " << IR_vector[i]->get_op1() <<endl;
			}

			// Else if call the cases for next iteration
			else if (IR_vector[i+2]->get_op_type() == "GT" ||
					IR_vector[i+2]->get_op_type() == "GE" ||
					IR_vector[i+2]->get_op_type() == "LT" ||
					IR_vector[i+2]->get_op_type() == "LE" ||
					IR_vector[i+2]->get_op_type() == "NE" ||
					IR_vector[i+2]->get_op_type() == "EQ"   ){
				if ( IR_vector[i+1]->get_op_type() == "STOREI" ||
					 IR_vector[i+1]->get_op_type() == "STOREF"){i++;}
			}
		}
		
		// System Halt insert
		cout << "sys halt" <<endl;


	}


}
