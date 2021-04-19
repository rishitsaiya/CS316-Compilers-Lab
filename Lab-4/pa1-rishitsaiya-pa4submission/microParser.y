%{
	#include <stdio.h> 
	#include <stdlib.h> 
	#include <string.h> 
	#include <ctype.h>

	int yylex();

	int variable_declaration = 0;
	int readwrite = 0;
	int temporary = 0;
	int adder[100];
	int adder_index = 0;
	int multiplier[100];
	int multiplier_index = 0;
	char* variable_type;
	char* table_names[100];
	int scope = -1;
	int num_blocks = 0 ;

	struct StrEntry{
		char* ID;
		char* Value;
	};

	struct VarEntry{
		char* ID;
		char* Type;
	};

	struct STable{
		char first;
		int num_vars;
		int num_strs;
		struct VarEntry vars[100];
		struct StrEntry strs[100];
	};

	struct CodeObject{
		char* instruction;
		char* codelist[1000];
		int num;
		char* result;
		char* type;
		char* factor;
		struct CodeObject* next;
	};

	struct STable symbol_table[100];
	struct CodeObject* current;

	void yyerror(const char *err);
%}

%token PROGRAM
%token _BEGIN
%token VOID
%token IDENTIFIER
%token INT
%token FLOAT
%token FLOATLITERAL
%token INTLITERAL
%token STRINGLITERAL
%token STRING
%token READ
%token WRITE
%token FUNCTION
%token RETURN
%token IF
%token ELSE
%token FI
%token FOR
%token ROF
%token END

%type <var_entry> var_decl param_decl id_list id_tail
%type <v> var_type primary
%type <s_entry> string_decl
%type <s> id str      

%union{
struct STable * s_table ;
struct CodeObject * code_object ;
struct VarEntry * var_entry ;
char * v;
struct StrEntry * s_entry ;
char * s;
}

%%
program:	PROGRAM id _BEGIN 
			{
				scope++; table_names[scope] = "GLOBAL";
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 

				current = malloc(sizeof(struct CodeObject()));
				for(int i = 0; i < 1000; i++) {
					current->codelist[i] = malloc(400*sizeof(char));
				}
				current->instruction = malloc(40*sizeof(char));
				current->result = malloc(10*sizeof(char));
				current->num = 0;
			}
			pgm_body END 
			{	
				for(int i = 0; i < current->num; i++){
					char *str = malloc(400*sizeof(char));
					strcat(str, current->codelist[i]);
					char *ptr = strtok(str, " ");

					if(!strcmp(ptr, "var") || !strcmp(ptr, "str")) {
						printf("%s\n",current->codelist[i]);
					}

					else if(!strcmp(ptr, "STOREI") || !strcmp(ptr, "STORER")) {
						printf("move");
						while((ptr = strtok(NULL, " ")) != NULL){
							printf(" %s", ptr);
						}
						printf("\n");
					}

					else if(!strcmp(ptr, "WRITEI") || !strcmp(ptr, "READI") || !strcmp(ptr, "WRITES") || !strcmp(ptr, "WRITER") || !strcmp(ptr, "READR")) {
						printf("sys ");
						char c;
						while((c = *ptr))  {
					      printf("%c", tolower(c));
					      ptr = ptr + 1;
					    }   
						while((ptr = strtok(NULL, " ")) != NULL){
							printf(" %s", ptr);
						}
						printf("\n");
					}

					else {
						printf("move");
						char *inst = malloc(50*sizeof(char));
						char *rem = malloc(50*sizeof(char));
						inst = ptr;
						while(*ptr)  {
							*ptr = tolower(*ptr);
					    	ptr = ptr + 1;
					    }    
						ptr = strtok(NULL, " ");
						printf(" %s", ptr);
						ptr = strtok(NULL, " ");
					    strcat(rem, ptr);
						ptr = strtok(NULL, " ");
						printf(" %s", ptr);
					    strcat(rem, " ");
					    strcat(rem, ptr);
						printf("\n%s %s\n", inst, rem);    
					}
				}
				printf("sys halt\n"); 
			}
			;
id:			IDENTIFIER 
			{
				if(variable_declaration==1 && scope == 0){
					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], "var "); 
					strcat(current->codelist[current->num], $$); 
					current->num++;
				}
				else if(readwrite == 1){
					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], current->instruction); 
					int i;
					for(i = 0; i < symbol_table[scope].num_strs; i++ ){
						if(!strcmp(symbol_table[scope].strs[i].ID,$$)){
							strcat(current->codelist[current->num], "S ");
							break;
						}
					}
					if(i == symbol_table[scope].num_strs){
						for(i = 0; i < symbol_table[0].num_strs; i++ ){
							if(!strcmp(symbol_table[0].strs[i].ID,$$)){
								strcat(current->codelist[current->num], "S ");
								break;
							}
						}
					}
					for(i = 0; i < symbol_table[scope].num_vars; i++ ){
						if(!strcmp(symbol_table[scope].vars[i].ID,$$)){
							if(!strcmp(symbol_table[scope].vars[i].Type,"INT")){
								strcat(current->codelist[current->num], "I ");
							}
							else{
								strcat(current->codelist[current->num], "R ");
							}
							break;
						}
					}
					if(i == symbol_table[scope].num_vars){
						for(i = 0; i < symbol_table[0].num_vars; i++ ){
							if(!strcmp(symbol_table[0].vars[i].ID,$$)){
								if(!strcmp(symbol_table[0].vars[i].Type,"INT")){
									strcat(current->codelist[current->num], "I ");
								}
								else{
									strcat(current->codelist[current->num], "R ");
								}
								break;
							}
						}
					}
					strcat(current->codelist[current->num], $$); 
					current->num++;
				}
			}
			;
pgm_body:	decl func_declarations 
			;
decl:		string_decl decl | var_decl decl |
			;
string_decl:	STRING id ':''=' str ';' 
				{
					if(symbol_table[scope].first == 'c')
						symbol_table[scope].first = 's';
					for(int i = 0; i < symbol_table[scope].num_strs; i++ ){
						if(!strcmp(symbol_table[scope].strs[i].ID,$2)){
							printf("DECLARATION ERROR %s\n", $2);
							return 0;
						}
					}
					for(int i = 0; i < symbol_table[scope].num_vars; i++ ){
						if(!strcmp(symbol_table[scope].vars[i].ID,$2)){
							printf("DECLARATION ERROR %s\n", $2);
							return 0;
						}
					}
					$$ = malloc(sizeof(struct StrEntry())); $$->ID = $2; $$->Value = $5; 
					symbol_table[scope].strs[symbol_table[scope].num_strs] = *($$);
					symbol_table[scope].num_strs++;

					current->type = "STRING";
					current->instruction = malloc(40*sizeof(char));
					strcat(current->instruction, "str");

					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], "str "); 
					strcat(current->codelist[current->num], $2); 
					strcat(current->codelist[current->num], " "); 
					strcat(current->codelist[current->num], $5); 
					current->num++;
					current->instruction = malloc(40*sizeof(char));
				}
				;
str:		STRINGLITERAL {}
			;
var_decl:	var_type 
			{
				if(symbol_table[scope].first == 'c')
					symbol_table[scope].first = 'v';
				variable_declaration = 1;   
				variable_type = $1;

				current->type = $1;
				current->instruction = malloc(40*sizeof(char));
				strcat(current->instruction, "var");
			} 
			id_list ';' {current->instruction = malloc(40*sizeof(char));}
			;
var_type:	FLOAT {} | INT {} 
			;
any_type:	var_type | VOID
			;
id_list:	id  
			{ 
				if(variable_declaration==1){
					for(int i = 0; i < symbol_table[scope].num_strs; i++ ){
						if(!strcmp(symbol_table[scope].strs[i].ID,$1)){
							printf("DECLARATION ERROR %s\n", $1);
							return 0;
						}
					}
					for(int i = 0; i < symbol_table[scope].num_vars; i++ ){
						if(!strcmp(symbol_table[scope].vars[i].ID,$1)){
							printf("DECLARATION ERROR %s\n", $1);
							return 0;
						}
					}
					$<var_entry>$ = malloc(sizeof(struct VarEntry())); $<var_entry>$->ID = $1; $<var_entry>$->Type = variable_type;
					symbol_table[scope].vars[symbol_table[scope].num_vars] = *($<var_entry>$); symbol_table[scope].num_vars++;
				}
			} 
			id_tail {}
			;
id_tail:	',' id  
			{
				if(variable_declaration==1){
					for(int i = 0; i < symbol_table[scope].num_strs; i++ ){
						if(!strcmp(symbol_table[scope].strs[i].ID,$2)){
							printf("DECLARATION ERROR %s\n", $2);
							return 0;
						}
					}
					for(int i = 0; i < symbol_table[scope].num_vars; i++ ){
						if(!strcmp(symbol_table[scope].vars[i].ID,$2)){
							printf("DECLARATION ERROR %s\n", $2);
							return 0;
						}
					}    
					$<var_entry>$ = malloc(sizeof(struct VarEntry())); $<var_entry>$->ID = $2; $<var_entry>$->Type = variable_type;
					symbol_table[scope].vars[symbol_table[scope].num_vars] = *($<var_entry>$); symbol_table[scope].num_vars++; 
				}
			}
			id_tail {} | 
			{
				variable_declaration = 0;
			}
			;
param_decl_list:	param_decl param_decl_tail |
					;
param_decl:	var_type id 
			{
				if(symbol_table[scope].first == 'c')
					symbol_table[scope].first = 'v';
				for(int i = 0; i < symbol_table[scope].num_strs; i++ ){
					if(!strcmp(symbol_table[scope].strs[i].ID,$2)){
						printf("DECLARATION ERROR %s\n", $2);
						return 0;
					}
				}
				for(int i = 0; i < symbol_table[scope].num_vars; i++ ){
					if(!strcmp(symbol_table[scope].vars[i].ID,$2)){
						printf("DECLARATION ERROR %s\n", $2);
						return 0;
					}
				}    
				$$ = malloc(sizeof(struct VarEntry())); $$->ID = $2; $$->Type = $1; 
				symbol_table[scope].vars[symbol_table[scope].num_vars] = *($$); symbol_table[scope].num_vars++;
			}
			;
param_decl_tail:	',' param_decl param_decl_tail |
					;
func_declarations:	func_decl func_declarations |
					;
func_decl:	FUNCTION any_type id  
			{
				scope++; table_names[scope] = $3;
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 
			}
			'(' param_decl_list ')' _BEGIN func_body END
			;
func_body:	decl stmt_list 
			;
stmt_list:	stmt stmt_list |
			;
stmt:		base_stmt | if_stmt | for_stmt
			;
base_stmt:	assign_stmt | read_stmt | write_stmt | return_stmt
			;
assign_stmt:	assign_expr ';'
				;
assign_expr:	id ':''=' 
				{
					current->instruction = malloc(40*sizeof(char));  
					strcat(current->instruction, "STORE");
					int i;    
					for(i = 0; i < symbol_table[scope].num_vars; i++ ){
						if(!strcmp(symbol_table[scope].vars[i].ID,$1)){
							if(!strcmp(symbol_table[scope].vars[i].Type,"INT")){
								strcat(current->instruction, "I ");
							}
							else{
								strcat(current->instruction, "R ");
							}
							break;
						}
					}
					if(i == symbol_table[scope].num_vars){
						for(i = 0; i < symbol_table[0].num_vars; i++ ){
							if(!strcmp(symbol_table[0].vars[i].ID,$1)){
								if(!strcmp(symbol_table[0].vars[i].Type,"INT")){
									strcat(current->instruction, "I ");
								}
								else{
									strcat(current->instruction, "R ");
								}
								break;
							}
						}
					}
				}
				expr 
				{
					strcat(current->codelist[current->num-1], $1);
				}
				;
read_stmt:	READ 
			{
				readwrite = 1;
				current->instruction = malloc(40*sizeof(char));
				strcat(current->instruction, "READ");
			}
			'(' id_list ')'';' 
			{
				current->instruction = malloc(40*sizeof(char)); 
			 	readwrite = 0; 
			}
			;
write_stmt:	WRITE 
			{
				readwrite = 1;
				current->instruction = malloc(40*sizeof(char));
				strcat(current->instruction, "WRITE");
			}
			'(' id_list ')'';' 
			{
				current->instruction = malloc(40*sizeof(char));
			 	readwrite = 0;
			}
			;
return_stmt:	RETURN expr ';'
				;
expr:		{}
			expr_prefix factor 
			{
				if(adder[adder_index] > 0){  
					strcat(current->instruction, current->factor);
					sprintf(current->result, "r%d", temporary);
					temporary++;  
					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], current->instruction);
					strcat(current->codelist[current->num], " ");
					strcat(current->codelist[current->num], current->result); 
					current->instruction = malloc(40*sizeof(char));
					current->num++;
					if(current->next != NULL){
						current->next->result = current->result;
						current->next->type = current->type;
						for(int i = 0; i < current->num; i++){
							current->next->codelist[i] = malloc(400*sizeof(char));
							current->next->codelist[i] = current->codelist[i];
						}
						current->next->num = current->num;
						struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
						temp = current->next->next;
						current = current->next;
						current->next = temp;
					}
					adder[adder_index] = 0;
				}
				if(adder_index == 0){
					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], current->instruction); 
					strcat(current->codelist[current->num], current->result); 
					strcat(current->codelist[current->num], " "); 
					current->instruction = malloc(40*sizeof(char));
					current->num++;
					if(current->next != NULL){
						current->next->result = current->result;
						current->next->type = current->type;
						for(int i = 0; i < current->num; i++){
							current->next->codelist[i] = malloc(400*sizeof(char));
							current->next->codelist[i] = current->codelist[i];
						}
						current->next->num = current->num;
						struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
						temp = current->next->next;
						current = current->next;
						current->next = temp;
					}
				}
			}
			;
expr_prefix:	expr_prefix factor 
				{
					if(adder[adder_index] > 0){
						strcat(current->instruction, current->factor);
						sprintf(current->result, "r%d", temporary);
						temporary++;  
						current->codelist[current->num] = malloc(400*sizeof(char));
						strcat(current->codelist[current->num], current->instruction);
						strcat(current->codelist[current->num], " ");
						strcat(current->codelist[current->num], current->result); 
						current->instruction = malloc(40*sizeof(char));
						current->num++;
						if(current->next != NULL){
							current->next->result = current->result;
							current->next->type = current->type;
							for(int i = 0; i < current->num; i++){
								current->next->codelist[i] = malloc(400*sizeof(char));
								current->next->codelist[i] = current->codelist[i];
							}
							current->next->num = current->num;
							struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
							temp = current->next->next;
							current = current->next;
							current->next = temp;
						}
					}
					adder[adder_index]++;

					struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
					temp->instruction = malloc(40*sizeof(char));
					for(int i = 0; i < current->num; i++){
						temp->codelist[i] = malloc(400*sizeof(char));
						temp->codelist[i] = current->codelist[i];
					}
					temp->num = current->num;
					temp->result = current->result;
					temp->factor = current->factor;
					temp->type = current->type;
					temp->next = current;

					current = temp;
				} 
				addop     
				{
					if(!strcmp(current->type, "INT")){
						strcat(current->instruction, "I ");
					}
					else if(!strcmp(current->type, "FLOAT")){
						strcat(current->instruction, "R ");
					}

					if(adder[adder_index] == 1){
						strcat(current->instruction, current->factor);
						strcat(current->instruction, " ");
					}
					else{
						strcat(current->instruction, current->result);
						strcat(current->instruction, " ");
					}
				}
				| 
				{adder[adder_index] = 0;}
				;
factor:		factor_prefix postfix_expr 
			{

				if(multiplier[multiplier_index] > 0){  
					strcat(current->instruction, current->factor);
					sprintf(current->result, "r%d", temporary);
					temporary++;  
					current->codelist[current->num] = malloc(400*sizeof(char));
					strcat(current->codelist[current->num], current->instruction);
					strcat(current->codelist[current->num], " ");
					strcat(current->codelist[current->num], current->result); 
					current->instruction = malloc(40*sizeof(char));
					current->num++;
					if(current->next != NULL){
						current->next->result = current->result;
						current->next->type = current->type;
						for(int i = 0; i < current->num; i++){
							current->next->codelist[i] = malloc(400*sizeof(char));
							current->next->codelist[i] = current->codelist[i];
						}
						current->next->num = current->num;
						struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
						temp = current->next->next;
						current = current->next;
						current->next = temp;
					}
					current->factor = current->result;
				}
			}
			;
factor_prefix:	factor_prefix postfix_expr
				{
					if(multiplier[multiplier_index] > 0){
						strcat(current->instruction, current->factor);
						sprintf(current->result, "r%d", temporary);
						temporary++;  
						current->codelist[current->num] = malloc(400*sizeof(char));
						strcat(current->codelist[current->num], current->instruction);
						strcat(current->codelist[current->num], " ");
						strcat(current->codelist[current->num], current->result); 
						current->instruction = malloc(40*sizeof(char));
						current->num++;
						if(current->next != NULL){
							current->next->result = current->result;
							current->next->type = current->type;
							for(int i = 0; i < current->num; i++){
								current->next->codelist[i] = malloc(400*sizeof(char));
								current->next->codelist[i] = current->codelist[i];
							}
							current->next->num = current->num;
							struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
							temp = current->next->next;
							current = current->next;
							current->next = temp;
						}
					}
					multiplier[multiplier_index]++;

					struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
					temp->instruction = malloc(40*sizeof(char));
					for(int i = 0; i < current->num; i++){
						temp->codelist[i] = malloc(400*sizeof(char));
						temp->codelist[i] = current->codelist[i];
					}
					temp->num = current->num;
					temp->result = current->result;
					temp->factor = current->factor;
					temp->type = current->type;
					temp->next = current;

					current = temp;
				} 
				mulop
				{
					if(!strcmp(current->type, "INT")){
						strcat(current->instruction, "I ");
					}
					else if(!strcmp(current->type, "FLOAT")){
						strcat(current->instruction, "R ");
					}

					if(multiplier[multiplier_index] == 1){
						strcat(current->instruction, current->factor);
						strcat(current->instruction, " ");
					}
					else{
						strcat(current->instruction, current->result);
						strcat(current->instruction, " ");
					}
				} 
				|        
				{
					multiplier[multiplier_index] = 0;
				}
				;
postfix_expr:	primary {} | call_expr {}
				;
call_expr:	id '(' expr_list ')'
			;
expr_list:	expr expr_list_tail |
			;
expr_list_tail:	',' expr expr_list_tail |        
				;
primary:	{
				adder_index++;
				multiplier_index++;
			}
			'(' expr ')' 
			{
				current->factor = current->result;
				adder_index--;
				multiplier_index--;  
			} 
			| id     
			{
				int i;    
				for(i = 0; i < symbol_table[scope].num_vars; i++ ){
					if(!strcmp(symbol_table[scope].vars[i].ID,$1)){
						if(!strcmp(symbol_table[scope].vars[i].Type,"INT")){
							current->type = "INT";
						}
						else{
							current->type = "FLOAT";
						}
						break;
					}
				}
				if(i == symbol_table[scope].num_vars){
					for(i = 0; i < symbol_table[0].num_vars; i++ ){
						if(!strcmp(symbol_table[0].vars[i].ID,$1)){
							if(!strcmp(symbol_table[0].vars[i].Type,"INT")){
								current->type = "INT";
							}
							else{
								current->type = "FLOAT";
							}
							break;
						}
					}
				}
				current->factor = $1;
			}
			| INTLITERAL
			{
				struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
				temp->instruction = malloc(40*sizeof(char));
				for(int i = 0; i < current->num; i++){
					temp->codelist[i] = malloc(400*sizeof(char));
					temp->codelist[i] = current->codelist[i];
				}
				temp->num = current->num;
				temp->result = current->result;
				temp->factor = current->factor;
				temp->type = current->type;
				temp->next = current;

				current = temp;

				current->type = "INT";
				current->instruction = malloc(40*sizeof(char));
				strcat(current->instruction, "STOREI ");
				strcat(current->instruction, $$); 
				strcat(current->instruction, " "); 
				sprintf(current->result, "r%d", temporary);
				temporary++;  
				strcat(current->instruction, current->result);
				current->codelist[current->num] = malloc(400*sizeof(char));
				strcat(current->codelist[current->num], current->instruction); 
				current->num++;
				if(current->next != NULL){
					current->next->result = current->result;
					current->next->type = current->type;
					for(int i = 0; i < current->num; i++){
						current->next->codelist[i] = malloc(400*sizeof(char));
						current->next->codelist[i] = current->codelist[i];
					}
					current->next->num = current->num;    
					struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
					temp = current->next->next;
					current = current->next;
					current->next = temp;
					current->factor = malloc(10*sizeof(char));  
					strcat(current->factor, current->result);
				}
			} 
			| FLOATLITERAL
			{
				struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
				temp->instruction = malloc(40*sizeof(char));
				for(int i = 0; i < current->num; i++){
					temp->codelist[i] = malloc(400*sizeof(char));
					temp->codelist[i] = current->codelist[i];
				}
				temp->num = current->num;
				temp->result = current->result;
				temp->factor = current->factor;
				temp->type = current->type;
				temp->next = current;

				current = temp;
				
				current->type = "FLOAT";
				current->instruction = malloc(40*sizeof(char));
				strcat(current->instruction, "STORER ");
				strcat(current->instruction, $$); 
				strcat(current->instruction, " "); 
				sprintf(current->result, "r%d", temporary);
				temporary++;  
				strcat(current->instruction, current->result);
				current->codelist[current->num] = malloc(400*sizeof(char));
				strcat(current->codelist[current->num], current->instruction); 
				current->num++;
				if(current->next != NULL){
					current->next->result = current->result;
					current->next->type = current->type;
					for(int i = 0; i < current->num; i++){
						current->next->codelist[i] = malloc(400*sizeof(char));
						current->next->codelist[i] = current->codelist[i];
					}
					current->next->num = current->num;    
					struct CodeObject* temp = malloc(sizeof(struct CodeObject()));
					temp = current->next->next;
					current = current->next;
					current->next = temp;
					current->factor = malloc(10*sizeof(char));  
					strcat(current->factor, current->result);  
				}
			} 
			;
addop:		'+'
			{
				current->instruction = malloc(100*sizeof(char));
				strcat(current->instruction, "ADD");
			}
			|'-'
			{
				current->instruction = malloc(100*sizeof(char));
				strcat(current->instruction, "SUB");
			}
			;
mulop:		'*'
			{
				current->instruction = malloc(100*sizeof(char));
				strcat(current->instruction, "MUL");
			}
			|'/'
			{
				current->instruction = malloc(100*sizeof(char));
				strcat(current->instruction, "DIV");
			}
			;
if_stmt:	IF 
			{
				scope++; table_names[scope] = "BLOCK ";
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 
			}
			'(' cond ')' decl stmt_list else_part FI
			;
else_part:	ELSE 
			{
				scope++; table_names[scope] = "BLOCK ";
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 
			}
			decl stmt_list |
			;
cond:		expr compop expr
			;
compop:		'<'|'>'|'='|'!''='|'<''='|'>''='
			;
init_stmt:	assign_expr |
			;
incr_stmt:	assign_expr |
			;
for_stmt:	FOR 
			{
				scope++; table_names[scope] = "BLOCK ";
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 
			}
			'(' init_stmt ';' cond ';' incr_stmt ')' decl stmt_list ROF
			;
%%
