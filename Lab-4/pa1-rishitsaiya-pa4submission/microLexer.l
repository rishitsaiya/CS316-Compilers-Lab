%{
	#include "microParser.h"
	#include <stdio.h> 
	#include <stdlib.h> 
	#include <string.h> 
%}

DIGIT [0-9]
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
SPACE [\r\n\t ]
STRINGLITERAL ["]
COMMENT [#]
OPERATOR [:]|[+]|[-]|[*]|[/]|[=]|[!]|[<]|[>]|[(]|[)]|[,]|[;]

%%

{COMMENT}.+\n {}

{SPACE}+ {}

{DIGIT}+ {
	yylval.v = strdup(yytext);
	return INTLITERAL;
}

{DIGIT}+"."{DIGIT}* {
	yylval.v = strdup(yytext);
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
	yylval.s = strdup(yytext);
	return INT;
}

VOID  {
	return VOID;
}

STRING  {
	return STRING;
}

FLOAT  {
	yylval.s = strdup(yytext);
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

int yywrap()
{
  	return 1;
}
