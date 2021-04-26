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

/*Libraries and headers import*/
%{
	#include <iostream>
	#include <stdio.h>
	#include <utility>
	#include <vector>
	#include <string>
	#include "main.h"
	extern int yylex();
	extern char* yytext();
	extern int yyparse();
	extern int yylineno;
	using namespace std;

/*String standard vars declared*/
std::string global_name = "GLOBAL"; 
std::string block_name = "BLOCK";
std::string temp_name = "T";
std::string stack_sign = "$";
std::string lable_name = "label";

/*Local counters initiated*/
int block_counter = 0;
int temp_counter = -1;
int label_num = 0;
int scope_counter = 0;
int link_counter = 1;
int param_counter = 1;
int local_counter = 0;

/*Function parameters defined*/
bool in_function = false;
std::map<string, bool> func_var_map; /*Mapping for function vars used*/
std::map<string, bool> func_type_map; /*Mapping for function type used*/

/*vision parameter defined - (Used in main.h also)*/
std::vector<std::vision*> SymTabHead;

/*IR_code parameter also defined - (Used in main.h also)*/
std::vector<std::IR_code*> IR_vector;

/*stacks, maps used for labe counter, current mapping and vision tables*/
std::stack<int> label_counter;
std::map<symbol*, int> newMap;
std::map<symbol*, int>* currMap = &newMap;
std::vector<std::string*> scope_table;

/*Error message for unaccepted grammar*/
void yyerror(char const* msg)
{
	printf("Not accepted");
}
%}

%token TOKEN_EOF /*Token for End of File*/
%token TOKEN_INTLITERAL /*Token for Int Literal*/
%token TOKEN_FLOATLITERAL /*Token for Float Literal*/

%token TOKEN_PROGRAM /*Token for Program*/
%token TOKEN_BEGIN /*Token for Begin*/
%token TOKEN_END /*Token for End*/
%token TOKEN_FUNCTION /*Token for Function*/
%token TOKEN_READ /*Token for Read*/
%token TOKEN_WRITE /*Token for Write*/
%token TOKEN_IF /*Token for If loop*/
%token TOKEN_ELSE /*Token for Else*/
%token TOKEN_FI /*Token for If close*/
%token TOKEN_FOR /*Token for For loop*/
%token TOKEN_ROF /*Token for For close*/
%token TOKEN_RETURN /*Token for Return*/
%token <tok_numer> TOKEN_INT /*Token for token containing int number*/
%token TOKEN_VOID /*Token for Void*/
%token TOKEN_STRING /*Token for String*/
%token <tok_numer> TOKEN_FLOAT /*Token for token containing float number*/
%token TOKEN_OP_NE /*Token for Not Equal*/
%token TOKEN_OP_PLUS /*Token for Add*/
%token TOKEN_OP_MINS /*Token for Subtract*/
%token TOKEN_OP_STAR /*Token for Multiply*/
%token TOKEN_OP_SLASH /*Token for Divide*/
%token TOKEN_OP_EQ /*Token for Equal to*/
%token TOKEN_OP_NEQ /*Token for Not Equal to*/
%token TOKEN_OP_LESS /*Token for Less than*/
%token TOKEN_OP_GREATER /*Token for Greater than*/
%token TOKEN_OP_LP /*Token for Left Paranthesis*/
%token TOKEN_OP_RP /*Token for Right Paranthesis*/
%token TOKEN_OP_SEMIC /*Token for Semi Colon*/
%token TOKEN_OP_COMMA /*Token for Comma*/
%token TOKEN_OP_LE /*Token for Less than or Equal to*/
%token TOKEN_OP_GE /*Token for Greater than or Equal to*/

%token TOKEN_STRINGLITERAL /*Token for String Literal*/
%token <str> TOKEN_IDENTIFIER /*Token for Token Identifier*/
%start program /*Program Start*/

/*specifics of entire collection of possible data types for semantic values associated with grammar*/
%union{
	std::string * str; /*String str declared*/
	int tok_numer; /*Token number declared*/
	std::vector <std::string*> * svec; /*String vector svec defined*/
	std::nodeAST* nodeAST; /*AST Node defined*/
	std::vector <std::nodeAST*>* expr_vector; /*Expression vector defined*/
}

/*Above semantic values defined with names*/
%type <tok_numer> var_type compop any_type 
%type <str> id str
%type <svec> id_tail id_list
%type <nodeAST> primary factor_prefix postfix_expr mulop addop factor expr_prefix expr assign_expr call_expr
%type <expr_vector> expr_list_tail expr_list

%%
program:	TOKEN_PROGRAM id TOKEN_BEGIN{ /*Global vision declared*/
std::vision * globalScope = new std::vision(global_name); /*vision added*/
SymTabHead.push_back(globalScope); /*Global vision added to symbol Head Table*/

std::IR_code * start_code = new std::IR_code("IR", "code", "", "", temp_counter); /*Code started (IR)*/
IR_vector.push_back(start_code); /*Add start_code of IR_code data type to IR_vector*/
}
pgm_body TOKEN_END{};

id:			TOKEN_IDENTIFIER{$$ = yylval.str;};

pgm_body:	decl{
				std::IR_code * push_code = new std::IR_code("PUSH", "", "", "", temp_counter); /*Function Declaration started here*/
				/*Add 5 fields to IR vector*/
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				IR_vector.push_back(push_code);
				/*Add JSR to IR vector*/
				std::IR_code * main_code = new std::IR_code("JSR", "", "", "main", temp_counter);
				IR_vector.push_back(main_code);
				/*Add Halt to IR vector*/
				std::IR_code * halt_code = new std::IR_code("HALT", "", "", "", temp_counter);
				IR_vector.push_back(halt_code);

} func_declarations{};

decl:		string_decl decl{/*String Declaration*/} 
		|	var_decl decl{}
		|	;

string_decl:	TOKEN_STRING id TOKEN_OP_NE str TOKEN_OP_SEMIC{ /*Structure of string*/
	symbol *newSym = new std::symbol($2, $4, TOKEN_STRING, 0);
	SymTabHead.back() -> insert_record(*($2) ,newSym);
	std::IR_code * string_decl = new std::IR_code("STRING_DECL", *$2, "", *$4, temp_counter);
	/*If in_function, is false, then push the new string declaration to IR_vector*/
	if (in_function == false){
		IR_vector.push_back(string_decl);
	}
	/*Increase the counter by 1*/
	else{
		link_counter = link_counter + 1;
	}
	/*Map the func_var with in_function*/
	func_var_map[*$2] = in_function;
};

str:		TOKEN_STRINGLITERAL{
	//Return the string name
	$$ = yylval.str;};

var_decl:	var_type id_list TOKEN_OP_SEMIC{
	std::string s_type = "";
	//Iterating over the number of variables in id_list
	for(int i = $2 -> size() -1; i >= 0; i--){
		//Reducing the local_counter from 0 to as this points to the location of the ID on stack
		//Stack grows in downwards direction
		if (in_function == true)
		{
			local_counter = local_counter - 1;
		}
		//Create new symbol with value set to NULL, type set to var_type and local_counter points 
		//its location in stack
		std::symbol * newSym = new std::symbol((*$2)[i], NULL, $1, local_counter);
		//IR Code Comment for debugging
		cout << ";" <<  *( (*$2)[i] ) << " the local counter: " << local_counter <<endl;
		//Add the symbol to the last vision in the symbol table
		SymTabHead.back() -> insert_record(*( (*$2)[i] ) , newSym);
		func_var_map[*( (*$2)[i] )] = in_function;
		//Define the symbol type for the IR code
		if($1 == TOKEN_INT){
			s_type = "INT_DECL";
		}
		else if($1 == TOKEN_FLOAT){
			s_type = "FLOAT_DECL";
		}
		//Create the IR code
		std::IR_code * string_decl = new std::IR_code(s_type, *( (*$2)[i] ), "", "", temp_counter);
		if (in_function == false){
			//Push the IR code to the IR Code vector, if the variable declaration is not in function
			IR_vector.push_back(string_decl);
		}
		else{
			//Increment the link counter for the function
			link_counter = link_counter + 1;
		}
		//IR_vector.push_back(string_decl);
	}
};

var_type:	TOKEN_FLOAT{
	//Returns the type of the variable (FLOAT)
	$$ = TOKEN_FLOAT;}
		|	TOKEN_INT{
			//Returns the type of the variable (INT)
			$$ = TOKEN_INT; };

any_type:	var_type{
	//Returns the data type for function return
	$$ = $1;}
		|	TOKEN_VOID{
			//Returns VOID if function return type is VOID
			$$ = TOKEN_VOID;};


//declaring identifiers one here and other in id_tail
id_list:	id id_tail{
	//Return a vector of strings of id. Eg: a,b,c; returns vector{a,b,c}
						$$ = $2; $$ -> push_back($1);
						}

id_tail:	TOKEN_OP_COMMA id id_tail{
	//Same thing as above, recursively defined
	$$ = $3; $$ -> push_back($2);}
		|	{
			//Returns the vector to add the ID
			std::vector<std::string*>* temp = new std::vector<std::string*>; $$ = temp; };

// same grammer as id_list but used as parameters to function
// func_decl calls this grammer to have one or more parameter to declare
param_decl_list:	param_decl param_decl_tail{}
				|	;

// parameter declaration with variable type as var_type and identifier
param_decl:	var_type id{
	// defining new symbol
	std::symbol * newSym = new std::symbol($2, NULL, $1, ++param_counter);
	// updating SymTabHead with new symbol
	SymTabHead.back() -> insert_record(*($2) , newSym);
	// updating variable map with variable as in_function variable
	func_var_map[*($2)] = in_function;

};

// recursive grammer to declare zero or more parameters
param_decl_tail:	TOKEN_OP_COMMA param_decl param_decl_tail{}
				|	;

// recursive grammer to declare zero or more functions
func_declarations:   func_decl func_declarations{}
				|	;

// function declaration 
func_decl:	TOKEN_FUNCTION any_type id {
	//add function vision
	std::vision * funcScope = new std::vision(*$3);
	// updating SymTabHead with new function's vision
	SymTabHead.push_back(funcScope);
	//map_index = 0;
	//add label name
	// generating label for function in IR code
	std::IR_code *func_code = new std::IR_code("LABEL", "", "", *$3, temp_counter);
	// updating IR_vector with func_code
	IR_vector.push_back(func_code);
	// setting in_function true
	in_function = true;
	// updating map for function
	if($2 == TOKEN_INT){
		func_type_map[*($3)] = true;
	}
	else{
		func_type_map[*($3)] = false;
	}
	// generating rest of function body
	}TOKEN_OP_LP{param_counter = 1; local_counter = 0;
	// grammer for parameter list
	} 
	param_decl_list TOKEN_OP_RP {
	// function body beginning
	}
	TOKEN_BEGIN func_body{ 
	// exiting function and thus setting in_function variable to false
	}
	TOKEN_END{in_function = false;};

// grammer for function body declaration
func_body:	{link_counter = 1;}
			decl{
				std::string link_counter_str = std::to_string(static_cast<long long>(link_counter));
				// generating IR link code fot link_counter_str
				std::IR_code *link_code = new std::IR_code("LINK", link_counter_str, "", "", link_counter);
				// pushing IR code to IR_vector
				IR_vector.push_back(link_code);
			} stmt_list{};

// recursive grammer to generate statements 
stmt_list:	stmt stmt_list{};
		|

// broadly separating stmt into 3 categories
stmt:		base_stmt{}
		|	if_stmt{}
		|	for_stmt{};

base_stmt:	assign_stmt{}
		|	read_stmt{}
		|	write_stmt{}
		|	return_stmt{};

assign_stmt:	assign_expr TOKEN_OP_SEMIC{																/*print the 3 address code to vector*/
					if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){	/*This will return bool value whether it is int or float*/
						if(($1->get_right_node())->get_int_or_float() == true){		/*assign int value*/
							std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Convert to string*/
							std::string s = temp_name + temp_counter_str;											/*concatenate string*/
							if(($1->get_right_node())->get_node_type() == name_value){								/*if node type is name_value*/
								s = ($1->get_right_node())->get_name();												/*s is assigned it's name*/
							}
							std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);	/*
							assign new IR Node*/
							IR_vector.push_back(assign_int);	/*Push that IRnode in Vector*/
						}
						else if(($1->get_right_node())->get_int_or_float() == false){	/*assign float value*/
							std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Convert to string*/
							std::string s = temp_name + temp_counter_str;											/*concatenate string*/
							if(($1->get_right_node())->get_node_type() == name_value){								/*if node type is name_value*/
								s = ($1->get_right_node())->get_name();												/*s is assigned it's name*/
							}
							std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);	/*
							assign new IR Node*/
							IR_vector.push_back(assign_float);	/*Push that IR_node in Vector*/
						}
					}
					else{
						//assign type error
					}
	};

assign_expr:	id TOKEN_OP_NE expr{			/*Set the assigned Expr Node*/
									std::nodeAST * assign_node = new nodeAST();	/*create assign node*/
									assign_node->change_node_type(operator_value);	/*assign its node type*/
									assign_node->change_operation_type(TOKEN_OP_NE);	/*Assign operation type*/
									//create the id node
									std::nodeAST * id_node = new nodeAST();	/*Create the id node*/
									id_node -> change_node_type(name_value);	/*assign its node type*/
									std::string s = *($1);	/*store its pointer in the string*/

									//id_node -> add_name(*($1));
									//find out the type of the id by looking up the symbol table need to use for loop later
									int temp;
									if (func_var_map[*($1)])	/*if that variable is present or mapped then,*/
									{
										temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() );	/*get the type of the symbol*/
										id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/

										int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*get the position*/
										std::string stack_label = std::to_string(static_cast<long long>(stack_num));	/*get lable from that position*/
										s = stack_sign + stack_label;	/*concatenate strings*/
										id_node -> add_name(s);		/*assign the name to id node*/
									}
									else{	/*if that variable is absent or not mapped then,*/
										temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );	/*get the type of the symbol*/
										id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/
										id_node -> add_name(s);		/*add the string *($1)*/
									}
									id_node -> change_int_or_float(temp == TOKEN_INT);	/*assign that token type to id_node*/
									assign_node -> add_left_child(id_node);	/*add left child to assign_node*/
									assign_node -> add_right_child($3);		/*add right child to assign_node*/
									assign_node->change_int_or_float((temp == TOKEN_INT));	/*assign that token type to assign_node*/

									//set the assign_expr type
									$$ = assign_node; 	/*Set the assign expr type*/
};

read_stmt:		TOKEN_READ TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{	/*print the 3-address read code to vector*/
				for(int i = ($3->size()) - 1; i >= 0; --i){
					std::string s_type = "";
					if(func_var_map[*( (*$3)[i] )]){	/*need to check the vision use loop later*/
						if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){ /*If symbol type is int*/
							s_type = "READI";																		/*assign it as read int*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){	/*If symbol type is float*/
							s_type = "READF";																		/*assign it as read float*/
						}
					}
					else{	/*If not defined it will check the type from start*/
						if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "READI";
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "READF";
						}
					}
					std::string s = *( (*$3)[i] );	/*store that into a string*/
					if (func_var_map[s])	/*check whether it is mapped or not*/
					{
						int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*get the position*/
						std::string stack_label = std::to_string(static_cast<long long>(stack_num));		/*get the label from that position*/
						s = stack_sign + stack_label;	/*concatenate the strings*/
					}
					std::IR_code * read_code = new IR_code(s_type, "", "", s, temp_counter);	/*ceate ner IR code as read code*/
					IR_vector.push_back(read_code);												/* Push that read code into the vector*/
				}
};

write_stmt:		TOKEN_WRITE TOKEN_OP_LP id_list TOKEN_OP_RP TOKEN_OP_SEMIC{		/*Write the 3-address code and store it in vector*/
				for(int i = ($3->size()) - 1; i >= 0; --i){
					std::string s_type = "";	/*Initialized empty string*/
					//need to check the vision use loop later
					if(func_var_map[*( (*$3)[i] )]){
						if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "WRITEI";	/*If token type is int then set op type is Write int*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "WRITEF";	/*If token type is float then set op type is Write float*/
						}
						else if((SymTabHead[SymTabHead.size() - 1]->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
							s_type = "WRITES";	/*If token type is string then set op type is Write string*/
						}
					}
					else{
						if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_INT){
							s_type = "WRITEI";	/*If token type is int then set op type is Write int*/
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_FLOAT){
							s_type = "WRITEF";	/*If token type is float then set op type is Write float*/
						}
						else if((SymTabHead.front()->get_tab())[*( (*$3)[i] )] -> get_type() == TOKEN_STRING){
							s_type = "WRITES";	/*If token type is string then set op type is Write string*/
						}
					}
					std::string s = *( (*$3)[i] );	/*store the op type */
					if (func_var_map[s])
					{
						int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() );	/*If mapped get location*/
						std::string stack_label = std::to_string(static_cast<long long>(stack_num));	/*get label from that location*/
						s = stack_sign + stack_label;		/*concatenate the sign and label*/
					}
					std::IR_code * write_code = new IR_code(s_type, s, "", "", temp_counter);	/*Create new IR node as write code*/
					IR_vector.push_back(write_code);	/*push that node ino the vector*/
				}
};

return_stmt:	TOKEN_RETURN expr TOKEN_OP_SEMIC{	/*Returns the status of execution*/
				//need to store the expr onto stack
				std::string return_name = "";		/*Initialization of empty return name,datatype,dstination*/
				std::string data_type = "";
				std::string dest = "";
				if ($2->get_node_type() == name_value){		/*If node type is name_value,*/
					return_name = $2->get_name();	/*Set return name as the identity of that node*/
				}
				else{
					std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));	/*Store temp counter as string*/
					return_name = temp_name + temp_counter_str;		/*concatenate name and counter*/
				}
				if ($2->get_int_or_float()){	/*If int then true*/
					data_type = "STOREI";	/*Set data type as Store int*/
				}
				else{
					data_type = "STOREF";	/*Set data type as Store float*/
				}
				std::string param_counter_str = std::to_string(static_cast<long long>(param_counter+1));	/*increasing the parameter counter*/
				dest = stack_sign + param_counter_str;	/*initial + counter will point to destination to address*/
				std::IR_code * ret_addr = new IR_code(data_type, return_name, "", dest, temp_counter);	/*creating new IR node with dest address as return node*/
				IR_vector.push_back(ret_addr);	/*push return address into vector*/
				std::IR_code * unlink_code = new IR_code("UNLINK", "", "", "", temp_counter);	/*creating new IR node with temp counter as unlink node*/
				IR_vector.push_back(unlink_code);	/*push unlink code into vector*/
				std::IR_code * return_code = new IR_code("RET", "", "", "", temp_counter);	/*creating new IR node with data type RET as return node*/
				IR_vector.push_back(return_code);	/*push return code into vector*/
};

expr:			expr_prefix factor{
									if ($1 == NULL){
										//expr with only factor
										$$ = $2;
									}
									else{
											std::string s_op1 = "";
											std::string s_op2 = "" ;
											std::string s_result = "" ;
											std::string s_type = "" ;
											//Check if both prefix expression and factor are of the same type
											if($1->get_int_or_float() == $2->get_int_or_float()){
												//Assigns factor to be the right child of the nodeAST of prefix
												$1 -> add_right_child($2);
												//Check type of the prefix expression
												if($1->get_int_or_float()){
													//Operations on INT
													if($1->get_operation_type() == TOKEN_OP_PLUS){
														s_type = "ADDI";
													}
													else if($1->get_operation_type() == TOKEN_OP_MINS){
														s_type = "SUBI";
													}
												}
												else{
													//Operations on Float
													if($1->get_operation_type() == TOKEN_OP_PLUS){
														s_type = "ADDF";
													}
													else if($1->get_operation_type() == TOKEN_OP_MINS){
														s_type = "SUBF";
													}
												}
												
												if(($1->get_left_node())->get_node_type() == name_value){
													//If left node of prefix is of name_value type, set operand1 as the name
													s_op1 = ($1->get_left_node())->get_name();
												}
												else{
													//Else assign a temp to operand1
													s_op1 = ($1->get_left_node())->get_temp_count();
												}
												
												if(($1->get_right_node())->get_node_type() == name_value){
													//If right node of prefix is of name_value type, set operand2 as the name
													s_op2 = ($1->get_right_node())->get_name();
												}
												else{
													//Else assign a temp to operand2
													s_op2 = ($1->get_right_node())->get_temp_count();
												}
												//Create a temp to store the result
												std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
												s_result = temp_name + temp_counter_str;
												//set the temp counter in node factor
												$1->change_temp_count(s_result);
												//Create IR Code for the expression
												std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
												//Add IR Code to the IR Code vector
												IR_vector.push_back(add_code);
										}
										else{
											//wrong type
										}
									//Return the expression
									$$ = $1;
								}
							};

expr_prefix:	expr_prefix factor addop{
											if($1 == NULL){
												//If expr_prefix is NULL, initialise a addop nodeAST's
												//left child as factor. Right remains uninitialised
												$3 -> add_left_child($2);
												//Set datatype for the factor
												$3 -> change_int_or_float($2->get_int_or_float());
											}
											else{
												std::string s_op1 = "";
												std::string s_op2 = "" ;
												std::string s_result = "" ;
												std::string s_type = "" ;
												if($1->get_int_or_float() == $2->get_int_or_float()){
														//Right child is init to factor
														$1 -> add_right_child($2);
														//Left Child is init to prefix expression
														$3 -> add_left_child($1);
														//Data type for the resulting expression set
														$3 -> change_int_or_float($1->get_int_or_float());
														//Checking the type of the operation
														if($1->get_int_or_float()){
															//int op
															if($1->get_operation_type() == TOKEN_OP_PLUS){
																s_type = "ADDI";
															}
															else if($1->get_operation_type() == TOKEN_OP_MINS){
																s_type = "SUBI";
															}
														}
														else{
															//float op
															if($1->get_operation_type() == TOKEN_OP_PLUS){
																s_type = "ADDF";
															}
															else if($1->get_operation_type() == TOKEN_OP_MINS){
																s_type = "SUBF";
															}
														}
														
														if(($1->get_left_node())->get_node_type() == name_value){
															//If left nodeAST of prefix is a name_value type, set operand1 as its name
															s_op1 = ($1->get_left_node())->get_name();
														}
														else{
															//Else assign a temp as operand 1
															s_op1 = ($1->get_left_node())->get_temp_count();
														}
														if(($1->get_right_node())->get_node_type() == name_value){
															//If right nodeAST of prefix is a name_value type, set operand2 as its name
															s_op2 = ($1->get_right_node())->get_name();
														}
														else{
															//Else assign a temp as operand2
															s_op2 = ($1->get_right_node())->get_temp_count();
														}
														//Create a string to store a temp
														std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
														s_result = temp_name + temp_counter_str;
														//set the temp counter in node factor
														$1->change_temp_count(s_result);
														//Create IR Code for the expression
														std::IR_code * add_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
														//Add IR Code to the IR Code vector
														IR_vector.push_back(add_code);

												}
												else{
													//return error cant add int with float
												}
											}
											//Return the addop nodeAST
											$$ = $3;
										}
			|	{$$ = NULL;};

// grammer for factor
factor:			factor_prefix postfix_expr{
											// checking if first operand is null
											if ($1 == NULL){
											//assign result as second operand as first operand is null
												$$ = $2;
											}
											else{
											// if both operand are not null
											// initialize operand values as empty strings
												std::string s_op1 = "";
												std::string s_op2 = "" ;
												std::string s_result = "" ;
												std::string s_type = "" ;
												// check is operand 1 and operand 2 is int or float
												// to operate with arthimatic operator
												// check if both are of same type
												if($1->get_int_or_float() == $2->get_int_or_float()){
													// adding right child to first operand in ast
													$1 -> add_right_child($2);
													// checking is operand for int or float
													// if int use MULI and DIVI
													if($1->get_int_or_float()){
														//int op
														// check for operation type
														if($1->get_operation_type() == TOKEN_OP_STAR){
														// if operator is "*" then MULI
															s_type = "MULI";
														}
														else if($1->get_operation_type() == TOKEN_OP_SLASH){
														// if operator is "/" then DIVI
															s_type = "DIVI";
														}
													}
													else{
														// if operands are of type float
														//float op
														// check for operation type
														if($1->get_operation_type() == TOKEN_OP_STAR){
														// if operator is "*" then MUL
															s_type = "MULF";
														}
														else if($1->get_operation_type() == TOKEN_OP_SLASH){
														// if operator is "/" then DIV
															s_type = "DIVF";
														}
													}
													//set op1
													// check if operand has left child of type name_value
													if(($1->get_left_node())->get_node_type() == name_value){
														// if true assign the operand 1 equals to left child of node
														s_op1 = ($1->get_left_node())->get_name();
													}
													else{
														// else if not true assign a new temporary to operand 1
														s_op1 = ($1->get_left_node())->get_temp_count();
													}
													//set op2
													// check if operand 2 has right child of type name_value
													if(($1->get_right_node())->get_node_type() == name_value){
														// if true assign operand 2 the name of right child
														s_op2 = ($1->get_right_node())->get_name();
													}
													else{
														// else if not true assign a new temporary to it
														s_op2 = ($1->get_right_node())->get_temp_count();
													}
													// increment temp counter
													std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
													// assigning new temporary to result 
													s_result = temp_name + temp_counter_str;
													//set the temp counter in node factor
													$1->change_temp_count(s_result);
													//generating IR code for processed inst
													std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
													// pushing IR code to IR_vector
													IR_vector.push_back(factor_code);
													//cout << "if factor called " << $1->get_temp_count() << endl;
												}
												else{
													//wrong type
												}


												$$ = $1;
											}
										};

// recursive grammer for factor_prefix
factor_prefix:	factor_prefix postfix_expr mulop{
												// check if first operand is null
												if($1 == NULL){
													// adding left child in ast
													$3 -> add_left_child($2);
													// set the node int_or_float type
													// depends on child's type
													$3->change_int_or_float($2->get_int_or_float());

												}
												else{
													// if first operand is not null
													// if first and second operand are of same type to be able
													// to operate on given operation
													if($1->get_int_or_float() == $2->get_int_or_float()){
														// add right child to first operand
														$1 -> add_right_child($2);
														// add left child as first operand
														$3 -> add_left_child($1);
														// set node int_or_float value type
														$3 -> change_int_or_float($1->get_int_or_float());

														// initialize the operation variables
														std::string s_op1 = "";
														std::string s_op2 = "" ;
														std::string s_result = "" ;
														std::string s_type = "" ;

														// check if operation is over int or float to operate
														if($1->get_int_or_float()){
															// if int apply integer operations
															//int op
															// check operation type
															if($1->get_operation_type() == TOKEN_OP_STAR){
																// if operation type is "*" then MUL
																s_type = "MULI";
															}
															else if($1->get_operation_type() == TOKEN_OP_SLASH){
																// if operation type is "/" then DIV
																s_type = "DIVI";
															}
														}
														else{
															//float op
															// if operands aren't integer but float
															if($1->get_operation_type() == TOKEN_OP_STAR){
																// if operation type is "*" then MUL
																s_type = "MULF";
															}
															else if($1->get_operation_type() == TOKEN_OP_SLASH){
																// if operation type is "/" then DIV
																s_type = "DIVF";
															}
														}

														// check if operand 1 node type is name_value
														if(($1->get_left_node())->get_node_type() == name_value){
															// if true then assign operand 1 with name of left_node
															s_op1 = ($1->get_left_node())->get_name();
														}
														else{
															// if not true assign a new temporary to operand
															s_op1 = ($1->get_left_node())->get_temp_count();
															//cout << "test factor_prefix op1 " << s_type << " temp: " << s_op1 <<endl;
														}
														// check if operand 2 node type is name value
														if(($1->get_right_node())->get_node_type() == name_value){
														// if true assign right child name to variable
															s_op2 = ($1->get_right_node())->get_name();
														}
														else{
															// if not true assign a new temporary to operand 2
															s_op2 = ($1->get_right_node())->get_temp_count();
															//cout << "test factor_prefix op2 " << s_type << " temp: " << s_op2 <<endl;
														}
														// increment temp counter 
														std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
														// assign new temporary to result
														s_result = temp_name + temp_counter_str;
														//set the temp counter in node factor
														$1->change_temp_count(s_result);
														// generate IR code for processed operation
														std::IR_code * factor_code = new IR_code(s_type, s_op1, s_op2, s_result, temp_counter);
														// pushing IR code to IR_vector
														IR_vector.push_back(factor_code);

													}
													else{
													//	//return error cant add int with float
													}
												}
												$$ = $3;
												//try to add IR code

											}
			|	{$$ = NULL;};

postfix_expr:	primary{$$=$1;}
			|	call_expr{$$=$1;};	/*Call either of this function and pass the variable*/

call_expr:		id TOKEN_OP_LP expr_list TOKEN_OP_RP{
				std::IR_code * push_code = new IR_code("PUSH", "", "", "", temp_counter);	/*Create new IR code with data type as PUSH*/
				std::IR_code * push_reg = new IR_code("PUSHREG", "", "", "", temp_counter);	/*Create new IR code with data type as PUSHREG*/
				IR_vector.push_back(push_reg);
				IR_vector.push_back(push_code);												/*push both nodes into vector*/
				std::string s = "";
				for (int x = 0; x < $3->size(); x++)	/*for all expression in the list*/
				{
					if ((*$3)[x] -> get_node_type() == name_value)	/*if node type of that expression is name value*/
					{
						s = (*$3)[x] -> get_name();	/*store its symbol name*/
					}
					else{
						s = (*$3)[x] -> get_temp_count();	/*else store the counter*/
					}
					std::IR_code * push_para = new IR_code("PUSH", "", "", s, temp_counter);	/*Create new IR code with data type as PUSH with the name or counter*/
					IR_vector.push_back(push_para);	/*push that node into vector*/
				}
				//need to push the result of expr_list
				std::IR_code * jump_func = new IR_code("JSR", "", "", *$1, temp_counter);		/*Create new IR code with data type as JSR with parameter id*/
				IR_vector.push_back(jump_func);		/*push that node into vector*/
				std::IR_code * pop_code = new IR_code("POP", "", "", "", temp_counter);		/*Create new IR code with data type as POP*/
				std::IR_code * pop_reg = new IR_code("POPREG", "", "", "", temp_counter);	/*Create new IR code with data type as POPREG*/

				IR_vector.push_back(pop_code);	/*push that node into vector*/
				for (int x = 0; x < $3->size()-1; x++)	/*for all expression in the list except last one*/
				{
					std::IR_code * pop_para = new IR_code("POP", "", "", "", temp_counter);	/*Create new IR code with data type as POP with the counter*/
					IR_vector.push_back(pop_para);	/*push that node into vector*/
				}
				std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));	/*increasing the parameter counter*/
				s = temp_name + temp_counter_str;														/*concatenate name with counter*/
				std::IR_code * pop_ret = new IR_code("POP", "", "", s, temp_counter);		/*Create new IR code with data type as POP with the counter and with its Tempcounter (eg. T21)*/
				IR_vector.push_back(pop_ret);		/*push that node into vector*/
				IR_vector.push_back(pop_reg);		/*push that node into vector*/
				/*need to pop the result of function into an temp and store the temp into the call_expr node with the type of the function */ 
				std::nodeAST * caller_node = new nodeAST();		/*Create new object*/
				caller_node -> change_node_type(name_value);	/*assign node type to it*/
				caller_node -> add_name(s);						/*assign name to it*/
				caller_node -> change_int_or_float(func_type_map[*($1)]);	/*assign bool value (int = true; float = false) to it*/
				$$ = caller_node;	/*define caller node*/ 
};

expr_list:		expr expr_list_tail{
				$$ = $2;						/*assign 2nd argument value*/
				$$ -> push_back($1);			/*push 1st argument*/
}
			|	{std::vector<std::nodeAST*>* temp = new std::vector<std::nodeAST*>; $$ = temp;};;	/*declared new expr vector*/

expr_list_tail:	TOKEN_OP_COMMA expr expr_list_tail{		/*add the expr to the expr vector*/
				$$ = $3;
				$$ -> push_back($2);
		}
			|	{std::vector<std::nodeAST*>* temp = new std::vector<std::nodeAST*>; $$ = temp;};	/*declared new expr vector*/

primary:		TOKEN_OP_LP expr TOKEN_OP_RP{$$=$2;}
			|	id{
								std::nodeAST * id_node = new nodeAST();
								id_node -> change_node_type(name_value);	/*Create node and then assign its node type*/
								//id_node -> add_name(*($1));
								std::string s = (*($1));					/*Define new string with 1st argument*/
								if(func_var_map[*($1)] == true){			/*If that arg is mapped then,*/
									int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s] -> get_stack_pointer() ); /*Fetch out the postion*/
									std::string stack_label = std::to_string(static_cast<long long>(stack_num));	/*Fetch label from that position*/
									s = stack_sign + stack_label;			/*Define stack variable*/
									id_node -> add_name(s);
									int temp = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[*($1)] -> get_type() ); /*Get the unused temp symbol variable from stack*/
									id_node -> change_int_or_float(temp == TOKEN_INT);		/*Assign the type to it*/
								}
								else{
									int temp = ( (SymTabHead.front()->get_tab())[*($1)] -> get_type() );	/*Get unused temp variable*/
									id_node -> change_int_or_float(temp == TOKEN_INT);		/*Assign the type to it*/
									id_node -> add_name(s);									/*assign its name*/
								}																
								$$ = id_node;
							}
			|	TOKEN_INTLITERAL{											/*AST node*/
								std::nodeAST * int_node = new nodeAST();
								int_node -> change_node_type(int_value);
								int_node -> add_value(*(yylval.str));
								int_node -> change_int_or_float(true);		/*Create node and assign its type,value,int or float type*/
								$$ = int_node;
								/*try to store IR_code*/
								std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
								std::string s = temp_name + temp_counter_str;	/*Get variable for use*/
								std::IR_code * int_code = new IR_code("STOREI", *(yylval.str), "", s , temp_counter);	/*Create new node with its related parameters*/
								int_node -> change_temp_count(s);			/*Assign its temp count*/
								IR_vector.push_back(int_code);				/*push that node into vector*/
							}
			|	TOKEN_FLOATLITERAL{											/*AST node*/
									std::nodeAST * float_node = new nodeAST();
									float_node -> change_node_type(float_value);
									float_node -> add_value(*(yylval.str));
									float_node -> change_int_or_float(false);	/*Create node and assign its type,value,int or float type*/
									$$ = float_node;
									/*try to store IR_code*/
									std::string temp_counter_str = std::to_string(static_cast<long long>(++temp_counter));
									std::string s = temp_name + temp_counter_str;	/*Get variable for use*/
									std::IR_code * float_code = new IR_code("STOREF", *(yylval.str), "", s, temp_counter );
									/*set the temp counter*/
									float_node -> change_temp_count(s);
									IR_vector.push_back(float_code);		/*push that node into vector*/
								};

addop:			TOKEN_OP_PLUS{												/*Assign the node as ADD op node*/
								std::nodeAST * op_node = new nodeAST();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_PLUS);
								$$ = op_node;
							}
			|	TOKEN_OP_MINS{												/*Assign the node as SUB op node*/
								std::nodeAST * op_node = new nodeAST();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_MINS);
								$$ = op_node;
							};

mulop:			TOKEN_OP_STAR{												/*Assign the node as MUL op node*/
								std::nodeAST * op_node = new nodeAST();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_STAR);
								$$ = op_node;
							}
			|	TOKEN_OP_SLASH{												/*Assign the node as DIV op node*/
								std::nodeAST * op_node = new nodeAST();
								op_node -> change_node_type(operator_value);
								op_node -> change_operation_type(TOKEN_OP_SLASH);
								$$ = op_node;
							};

if_stmt:		TOKEN_IF{		/*add if block*/
	label_num = label_num + 2;
	label_counter.push(label_num - 1);		/*push that number into vector*/
} TOKEN_OP_LP cond TOKEN_OP_RP decl stmt_list{	/*jump to the end of for*/
												std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()+1));	/*Create new node with op LABEL*/
												std::string jump_s = lable_name + jump_label;		/*To return Label with its jmp counter*/
												std::IR_code * jump_IR = new IR_code("JUMP", "", "", jump_s, temp_counter);	/*Create new node with op LABEL*/
												IR_vector.push_back(jump_IR);		/*push that node into vector*/
												/*label for the beginning of the else*/
												std::string else_label = std::to_string(static_cast<long long>(label_counter.top()));	/*Create new node with op LABEL*/
												std::string else_s = lable_name + else_label;		/*To return Label with its counter*/
												std::IR_code * else_IR = new IR_code("LABEL", "", "", else_s, temp_counter);	/*Create new node with op LABEL*/
												IR_vector.push_back(else_IR);		/*push that node into vector*/
} else_part TOKEN_FI{
						std::string end_label = std::to_string(static_cast<long long>(label_counter.top()+1));		/*Get label counter*/
						std::string end_s = lable_name + end_label;										/*To return Label with its counter*/
						std::IR_code * end_IR = new IR_code("LABEL", "", "", end_s, temp_counter);		/*Create new node with op LABEL*/
						IR_vector.push_back(end_IR);		/*push that node into vector*/
						label_counter.pop();				/*pop the label counter*/
};

else_part:		TOKEN_ELSE{		/*add else block*/
	/*std::string block_counter_str = std::to_string(static_cast<long long>(++block_counter));
	std::string s = block_name + " " + block_counter_str;
	std::vision * else_blockScope = new std::vision(s);
	SymTabHead.push_back(else_blockScope);*/

} decl stmt_list{}
			|	;

// grammer for cond
cond:			expr compop expr{
									// intialize compop_str to empty str
									std::string compop_str = "";
									// switch case for compop to compop_str
									switch($2){
										case TOKEN_OP_LESS:
											compop_str = "GE";
											// convert "<" to GE
											break;
										case TOKEN_OP_GREATER:
											compop_str = "LE";
											// convert ">" to LE
											break;
										case TOKEN_OP_EQ:
											compop_str = "NE";
											// convert "=" to NE
											break;
										case TOKEN_OP_NEQ:
											compop_str = "EQ";
											// convert "!=" to EQ
											break;
										case TOKEN_OP_LE:
											compop_str = "GT";
											// convert "<=" to GT
											break;
										case TOKEN_OP_GE:
											compop_str = "LT";
											// convert ">=" to LT
											break;
									}
									// initialize variables 
									std::string s1 = "";
									std::string s2 = "";
									int cmp_type = 0;
									// check if operand 1 and 3 have same data type
									if($1->get_int_or_float() == $3->get_int_or_float()){
										// if true check if operand 1 has name value
										if($1->get_node_type() == name_value){
											// assign s1 to operand 1 name value
											s1 = $1->get_name();
											// check func_var_map for s1
											if (func_var_map[s1])
											{
												// getting stack number from symbol table
												int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s1] -> get_stack_pointer() );
												//generating stack label from stack number
												std::string stack_label = std::to_string(static_cast<long long>(stack_num));
												// generating new label
												s1 = stack_sign + stack_label;
											}
										}
										else{
											// if not true generate a new temporary
											s1 = $1->get_temp_count();
										}
										// check if operand 3 has node type name value
										if($3->get_node_type() == name_value){
											// if true assign s2 operand 3 name value
											s2 = $3->get_name();
											// check for func_var_map s2
											if (func_var_map[s2])
											{
												// getting stack number for symbol table
												int stack_num = ( (SymTabHead[SymTabHead.size() - 1]->get_tab())[s2] -> get_stack_pointer() );
												// generating stack label for stack number
												std::string stack_label = std::to_string(static_cast<long long>(stack_num));
												// generating new label
												s2 = stack_sign + stack_label;
											}
										}
										else{
											// if not true generate new temporary
											s2 = $3->get_temp_count();
										}
										// assign cmp type based on operand data type
										// if int cmp_type = 0
										if($1->get_int_or_float() == true){
											cmp_type = 0;
										}
										// if float cmp type = 1
										else if($1->get_int_or_float() == false){
											cmp_type = 1;
										}
									}
									else{
										//compare different type data
									}
									// getting jump label from label_counter head
									std::string jump_label = std::to_string(static_cast<long long>(label_counter.top()));
									// assign jump_s variable
									std::string jump_s = lable_name + jump_label;
									// generating IR code for compare operation
									std::IR_code * cond_IR = new IR_code(compop_str, s1, s2, jump_s, cmp_type);
									// pushing IR code to IR vector
									IR_vector.push_back(cond_IR);

};

// grammer for compop
// assignment operation for given operands
compop:			TOKEN_OP_LESS{$$ = TOKEN_OP_LESS; // assignment operation for given operand
}
			|	TOKEN_OP_GREATER{$$ = TOKEN_OP_GREATER; // assignment operation for given operand
			}
			|	TOKEN_OP_EQ{$$ = TOKEN_OP_EQ; // assignment operation for given operand
			}
			|	TOKEN_OP_NEQ{$$ = TOKEN_OP_NEQ; // assignment operation for given operand
			}
			|	TOKEN_OP_LE{$$ = TOKEN_OP_LE; // assignment operation for given operand
			}
			|	TOKEN_OP_GE{$$ = TOKEN_OP_GE; // assignment operation for given operand
			};

init_stmt:		assign_expr{
							//Check if both sides of the assignment statement have same type
							if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){
								//If the assignment is of INT type
								if(($1->get_right_node())->get_int_or_float() == true){
									//Create a temp to store the assigned value
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									//If nodeAST for the value being assigned is of name_value type, get it's name
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									//Create IR Code for the assignment statement, storing right node in the left
									std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
									//Add the IR Code to the IR Code vector
									IR_vector.push_back(assign_int);
								}
								//If the assignment is of FLOAT type
								else if(($1->get_right_node())->get_int_or_float() == false){
									//Create a temp to store the assigned value
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									//If nodeAST for the value being assigned is of name_value type, get it's name
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									//Create IR Code for the assignment statement, storing right node in the left
									std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
									//Add the IR Code to the IR Code vector
									IR_vector.push_back(assign_float);
								}
							}
							else{
								//Cannot assign different types
							}
}
			|	;

incr_stmt:		assign_expr{
							//Check if both sides of the assignment statement have same type
							if(($1->get_right_node())->get_int_or_float() == ($1->get_left_node())->get_int_or_float()){
								//If the assignment is of INT type
								if(($1->get_right_node())->get_int_or_float() == true){
								//Create a temp to store the assigned value
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									//If nodeAST for the value being assigned is of name_value type, get it's name
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									//Create IR Code for the assignment statement, storing right node in the left
									std::IR_code * assign_int = new IR_code("STOREI", s, "", (($1->get_left_node())->get_name()), temp_counter);
									//Add the IR Code to the IR Code vector
									IR_vector.push_back(assign_int);
								}
								//If the assignment is of FLOAT type
								else if(($1->get_right_node())->get_int_or_float() == false){
									//Create a temp to store the assigned value
									std::string temp_counter_str = std::to_string(static_cast<long long>(temp_counter));
									std::string s = temp_name + temp_counter_str;
									//If nodeAST for the value being assigned is of name_value type, get it's name
									if(($1->get_right_node())->get_node_type() == name_value){
										s = ($1->get_right_node())->get_name();
									}
									//Create IR Code for the assignment statement, storing right node in the left
									std::IR_code * assign_float = new IR_code("STOREF", s, "", (($1->get_left_node())->get_name()), temp_counter);
									//Add the IR Code to the IR Code vector
									IR_vector.push_back(assign_float);
								}
							}
							else{
								//Cannot Assign different Types
							}
}
			|	;

for_stmt:		TOKEN_FOR{//add for block
							/*std::string block_counter_str = std::to_string(static_cast<long long>(++block_counter));
							std::string s = block_name + " " + block_counter_str;
							std::vision * for_blockScope = new std::vision(s);
							SymTabHead.push_back(for_blockScope);*/

} TOKEN_OP_LP init_stmt TOKEN_OP_SEMIC{
										//Increment Label number by 2 as we need one label for "FOR START" and one for "FOR END"
										//Let the labels be named L1 and L2
										label_num = label_num + 2;
										//Add the label to the label stack
										label_counter.push(label_num);
										//Use L1 for marking the start of the loop, create a string fr it
										std::string label_counter_str = std::to_string(static_cast<long long>(label_counter.top() - 1));
										std::string label_s = lable_name + label_counter_str;
										//Create IR Code for the label
										std::IR_code * label_IR = new IR_code("LABEL", "", "", label_s, temp_counter);
										//Add IR Code to the IR Code vector
										IR_vector.push_back(label_IR);
										//Create IR Code for  start of FOR LOOP
										std::IR_code * label_for = new IR_code("FOR_START", "", "", "", temp_counter);
										//Add the IR Code to the IR Code vector
										IR_vector.push_back(label_for);
} cond TOKEN_OP_SEMIC{/*start for the incr_stmt*/
														//Create IR code which marks the beginning of the incr statement, (Useful for continue)
															std::IR_code * incr = new IR_code("INCR_START", "", "", "", temp_counter);
															//Add IR Code to the IR Code vector
															IR_vector.push_back(incr);
						} incr_stmt{
							//Marks the end of the INCR STMT
									//Create IR code which marks the end of the incr stmt
									std::IR_code * jump_code = new IR_code("INCR_END", "", "", "", temp_counter);
									//Add the IR Code to the IR Code vector
									IR_vector.push_back(jump_code);
						} TOKEN_OP_RP decl stmt_list{
														//Create IR Code which marks the end of the FOR LOOP
														std::IR_code * end_sig = new IR_code("FOR_END", "", "", "", label_counter.top());
														//Add the IR code to the IR Code vector
														IR_vector.push_back(end_sig);
														//Create label L2
														std::string end_label = std::to_string(static_cast<long long>(label_counter.top()));
														std::string end_lable_s = lable_name + end_label;
														//Add IR Code for label L2
														std::IR_code * end_code = new IR_code("LABEL", "", "", end_lable_s, temp_counter);
														//Add IR Code to the IR Code vector
														IR_vector.push_back(end_code);
														//Remove the label from the stack....Label number can be reused
														label_counter.pop();
						} TOKEN_ROF{};


%%
