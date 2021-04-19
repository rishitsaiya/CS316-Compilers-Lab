%{
	#include <stdio.h> 
	int yylex();
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

%%
program:	PROGRAM id _BEGIN pgm_body END
			;
id:			IDENTIFIER
			;
pgm_body:	decl func_declarations
			;
decl:		string_decl decl | var_decl decl |
			;
string_decl:	STRING id ':''=' str ';'
				;
str:		STRINGLITERAL
			;
var_decl:	var_type id_list ';'
			;
var_type:	FLOAT | INT
			;
any_type:	var_type | VOID
			;
id_list:	id id_tail
			;
id_tail:	',' id id_tail |
			;
param_decl_list:	param_decl param_decl_tail |
					;
param_decl:	var_type id
			;
param_decl_tail:	',' param_decl param_decl_tail |
					;
func_declarations:	func_decl func_declarations |
					;
func_decl:	FUNCTION any_type id '(' param_decl_list ')' _BEGIN func_body END
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
if_stmt:	IF '(' cond ')' decl stmt_list else_part FI
			;
else_part:	ELSE decl stmt_list |
			;
cond:		expr compop expr
			;
compop:		'<'|'>'|'='|'!''='|'<''='|'>''='
			;
init_stmt:	assign_expr |
			;
incr_stmt:	assign_expr |
			;
for_stmt:	FOR '(' init_stmt ';' cond ';' incr_stmt ')' decl stmt_list ROF
			;
%%
