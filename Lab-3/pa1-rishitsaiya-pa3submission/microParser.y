/*Acknowledgements: https://github.com/aswanthpp/Compiler-Design*/
%{
	#include <stdio.h> 
	#include <string.h> 
	#include <stdlib.h> 

	int yylex();

	int variable_declaration = 0;
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

	struct STable symbol_table[100];

	void yyerror(const char *err);
%}
/*Tokens*/
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
%type <v> var_type
%type <s_entry> string_decl
%type <s> id str

%union{
struct STable * s_table ;
struct VarEntry * var_entry ;
char * v;
struct StrEntry * s_entry ;
char * s;
}
/*Programs*/
%%
program:	PROGRAM id _BEGIN 
			{
				scope++; table_names[scope] = "GLOBAL";
				symbol_table[scope].first = 'c'; symbol_table[scope].num_vars = 0; symbol_table[scope].num_strs = 0; 
			}
			pgm_body END 
			{
				for(int j = 0; j <= scope; j++){

					if(j>0)
						printf("\n");    
					printf("Symbol table %s", table_names[j]);    
					if(!strcmp(table_names[j],"BLOCK ")){
						num_blocks++;
						printf("%d", num_blocks);    
					}
					printf("\n");    

					if(symbol_table[j].first == 's'){
						for(int i = 0; i < symbol_table[j].num_strs; i++ ){
							printf("name %s type %s value %s\n", symbol_table[j].strs[i].ID, "STRING", symbol_table[j].strs[i].Value);    
						}
						for(int i = 0; i < symbol_table[j].num_vars; i++ ){
							printf("name %s type %s\n", symbol_table[j].vars[i].ID, symbol_table[j].vars[i].Type);    
						}
					}
					else if(symbol_table[j].first == 'v'){
						for(int i = 0; i < symbol_table[j].num_vars; i++ ){
							printf("name %s type %s\n", symbol_table[j].vars[i].ID, symbol_table[j].vars[i].Type);    
						}
						for(int i = 0; i < symbol_table[j].num_strs; i++ ){
							printf("name %s type %s value %s\n", symbol_table[j].strs[i].ID, "STRING", symbol_table[j].strs[i].Value);    
						}
					}
				}
			}
			;
id:			IDENTIFIER {}
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
					symbol_table[scope].strs[symbol_table[scope].num_strs] = *($$); symbol_table[scope].num_strs++;
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
			} 
			id_list ';' {}
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
assign_expr:	id ':''=' expr
				;
read_stmt:	READ '(' id_list ')'';' 
			;
write_stmt:	WRITE '(' id_list ')'';' 
			;
return_stmt:	RETURN expr ';'
				;
expr:		expr_prefix factor
			;
expr_prefix:	expr_prefix factor addop |
				;
factor:		factor_prefix postfix_expr
			;
factor_prefix:	factor_prefix postfix_expr mulop |
			;
postfix_expr:	primary | call_expr
				;
call_expr:	id '(' expr_list ')'
			;
expr_list:	expr expr_list_tail |
			;
expr_list_tail:	',' expr expr_list_tail |
				;
primary:	'(' expr ')' | id | INTLITERAL | FLOATLITERAL
			;
addop:		'+'|'-'
			;
mulop:		'*'|'/'
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
