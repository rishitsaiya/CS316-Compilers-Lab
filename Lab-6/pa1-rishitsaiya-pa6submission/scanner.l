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

/* import libraries and headers/ */
%{
#include <string>
#include <vector>
#include "main.h"
#include "parser.hpp"
#include <stdio.h>
#include <iostream>

using namespace std;
%}

/*Adding alpha numerics grammar*/
DIGIT	[0-9]
LETTER	[A-Za-z]
ID		{LETTER}({LETTER}|{DIGIT})*

%option noyywrap
%option yylineno

/*Define tokens and actions for grammar key words*/
%%
PROGRAM	{return TOKEN_PROGRAM;} /*Program Token*/
BEGIN	{return TOKEN_BEGIN;} /*Begin Token*/
END	{return TOKEN_END;} /*End Token*/
FUNCTION	{return TOKEN_FUNCTION;} /*Function Token*/
READ	{return TOKEN_READ;} /*Read Token*/
WRITE	{return TOKEN_WRITE;} /*Write Token*/
IF 	{return TOKEN_IF;} /*If loop start Token*/
ELSE	{return TOKEN_ELSE;} /*Else loop Token*/
FI 	{return TOKEN_FI;} /*If loop close Token*/
FOR	{return TOKEN_FOR;} /*For loop Token*/
ROF	{return TOKEN_ROF;} /*For loop close Token*/
RETURN 	{return TOKEN_RETURN;} /*Return Token*/
INT 	{yylval.str = new string(yytext); return TOKEN_INT;} /*Int Token*/
VOID	{return TOKEN_VOID;} /*Void Token*/
STRING 	{yylval.str = new string(yytext); return TOKEN_STRING;} /*String Token*/
FLOAT {yylval.str = new string(yytext); return TOKEN_FLOAT;} /*Float Token*/

{ID}					{yylval.str = new string(yytext); return TOKEN_IDENTIFIER;} /*Identifier token*/

{DIGIT}+				{yylval.str = new string(yytext); return TOKEN_INTLITERAL;} /*For numbers token*/

{DIGIT}*"."{DIGIT}+		{yylval.str = new string(yytext); return TOKEN_FLOATLITERAL;} /*Float numbers token*/

":="	{return TOKEN_OP_NE;} // Returns relevent token to microParser.yy
"+"	{return TOKEN_OP_PLUS;} // Returns relevent token to microParser.yy
"-"	{return TOKEN_OP_MINS;} // Returns relevent token to microParser.yy
"*"	{return TOKEN_OP_STAR;} // Returns relevent token to microParser.yy
"/"	{return TOKEN_OP_SLASH;} // Returns relevent token to microParser.yy
"="	{return TOKEN_OP_EQ;} // Returns relevent token to microParser.yy
"!="	{return TOKEN_OP_NEQ;} // Returns relevent token to microParser.yy
"<"	{return TOKEN_OP_LESS;} // Returns relevent token to microParser.yy
">"	{return TOKEN_OP_GREATER;} // Returns relevent token to microParser.yy
"("	{return TOKEN_OP_LP;} // Returns relevent token to microParser.yy
")"	{return TOKEN_OP_RP;} // Returns relevent token to microParser.yy
";"	{return TOKEN_OP_SEMIC;} // Returns relevent token to microParser.yy
","	{return TOKEN_OP_COMMA;} // Returns relevent token to microParser.yy
"<="	{return TOKEN_OP_LE;} // Returns relevent token to microParser.yy
">=" {return TOKEN_OP_GE;} // Returns relevent token to microParser.yy
"#".* {}
\"([^\"\n]|\"\")*\"			{yylval.str = new string(yytext); return TOKEN_STRINGLITERAL;} /*String Literal tokens*/
"--".*\n			{/* deleted */} /*Comment token*/
[ \t\n\r]+			{/* deleted */} /*Tab, new line, nothing special tokens*/
%%
