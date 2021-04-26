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
#include "nodeAST.h"

// Class nodeAST
namespace std{
	nodeAST::nodeAST(){ //Initial values sent
		type = undefinded; // Node type
		left_node = NULL; // Left Node
		right_node = NULL; // Right Node
		Operation_type = 0; // Operation Type initialized to 0
		// Value, id_name, int_or_float set to true and temp_count initialized empty
		value = "";
		id_name = "";
		int_or_float = true;
		temp_count = "";
	}

	nodeAST::~nodeAST(){ // Function nodeAST type
	}

	void nodeAST::change_node_type(AST_Node_type n_type){ // Function to change node type
		type = n_type;
	}

	AST_Node_type nodeAST::get_node_type(){ // Function to fetch node type
		return type;
	}

	void nodeAST::change_operation_type(int op_type){ // Function to change operation type
		Operation_type = op_type;
	}

	int nodeAST::get_operation_type(){ // Function to fetch operation type
		return Operation_type;
	}

	void nodeAST::add_name(string name_string){ // Function to add name in AST
		id_name = name_string;
	}

	void nodeAST::add_value(string var_value){ // Function to add value in AST
		value = var_value;
	}

	string nodeAST::get_name(){ // Function to get name
		return id_name;
	}

	string nodeAST::get_value(){ // Function to get value
		return value;
	}

	void nodeAST::add_left_child(nodeAST* left){ // Function to add left child
		left_node = left;
	}

	void nodeAST::add_right_child(nodeAST* right){ // Function to add right child
		right_node = right;
	}

	nodeAST* nodeAST::get_left_node(){ // Function to fetch left node
		return left_node;
	}

	nodeAST* nodeAST::get_right_node(){ // Function to fetch right node
		return right_node;
	}

	void nodeAST::change_int_or_float(bool set){ // Function to set var when int/float is changed
		int_or_float = set;
	}

	bool nodeAST::get_int_or_float(){ // Function to fetch int/float
		return int_or_float;
	}

	void nodeAST::change_temp_count(string number){ // Function to change var temp_count
		temp_count = number;
	}

	string nodeAST::get_temp_count(){ // Function to fetch temp_count
		return temp_count;
	}

	IR_code::IR_code(string op_type, string op1, string op2, string result, int count){ // IR Code struct type
		op_type_code = op_type; // Operation Type
		op1_code = op1; // Operand 1
		op2_code = op2; // Operand 2
		result_code = result; // Result store
		reg_counter = count; // Register Counter
	}
	IR_code::~IR_code(){ // IR Code function

	}
	string IR_code::get_op_type(){ // Get operation type
		return op_type_code;
	}
	string IR_code::get_op1(){ // Fetch Operand 1
		return op1_code;
	}
	string IR_code::get_op2(){ // Fetch Operand 2
		return op2_code;
	}
	string IR_code::get_result(){ // Fetch Result
		return result_code;
	}
	int IR_code::get_reg_counter(){ // Fetch Register Counter
		return reg_counter;
	}


}
