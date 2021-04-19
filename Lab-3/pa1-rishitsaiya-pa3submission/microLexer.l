/*Acknowledgements: https://github.com/aswanthpp/Compiler-Design*/
%{
	#include "microParser.h"
	#include <stdio.h> 
	#include <stdlib.h> 
	#include <string.h> 
%}
/*Regex*/
DIGIT [0-9]
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
SPACE [\r\n\t ]
STRINGLITERAL ["]
COMMENT [#]
OPERATOR [:]|[+]|[-]|[*]|[/]|[=]|[!]|[<]|[>]|[(]|[)]|[,]|[;]

/*Tokens*/
%%
{COMMENT}.+\n {}

{SPACE}+ {}

{DIGIT}+ {
	return INTLITERAL;
}

{DIGIT}+"."{DIGIT}* {
	return FLOATLITERAL;
}

BEGIN  {
	return _BEGIN;
}

PROGRAM  {
	return PROGRAM;
}

END  {
	return END;
}

FUNCTION  {
	return FUNCTION;
}

READ  {
	return READ;
}

WRITE  {
	return WRITE;
}

IF  {
	return IF;
}

ELSE  {
	return ELSE;
}

FI  {
	return FI;
}

FOR  {
	return FOR;
}

ROF  {
	return ROF;
}

RETURN  {
	return RETURN;
}

INT  {
	yylval.v = strdup(yytext);
	return INT;
}

VOID  {
	return VOID;
}

STRING  {
	return STRING;
}

FLOAT  {
	yylval.v = strdup(yytext);
	return FLOAT;
}

{STRINGLITERAL}[^"]+{STRINGLITERAL} {
	yylval.s = strdup(yytext);
	return STRINGLITERAL;
}

{IDENTIFIER} {
	yylval.s = strdup(yytext);
	return IDENTIFIER;
}

{OPERATOR} {
	return *yytext;
}

%%
/*yywrap*/
int yywrap(){
  	return 1;
}
