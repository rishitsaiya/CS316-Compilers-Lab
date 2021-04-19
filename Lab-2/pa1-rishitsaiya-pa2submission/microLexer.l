%{
	#include "microParser.h"
%}

DIGIT [0-9]
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
SPACE [\r\n\t ]
STRINGLITERAL ["]
COMMENT (#|--).*\n
OPERATOR [:]|[+]|[-]|[*]|[/]|[=]|[!]|[<]|[>]|[(]|[)]|[,]|[;]

%%

{COMMENT} {}

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
	return INT;
}

VOID  {
	return VOID;
}

STRING  {
	return STRING;
}

FLOAT  {
	return FLOAT;
}

{STRINGLITERAL}[^"]+{STRINGLITERAL} {
	return STRINGLITERAL;
}

{IDENTIFIER} {
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
