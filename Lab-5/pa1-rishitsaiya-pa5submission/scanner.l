%{
    /*
        Acknowledgement(s): (Akshat Karani)
    */
   
    #include <iostream>
    #include <string>
    #include <vector>
    #include "headers/ast.hpp"
    #include "headers/codeObject.hpp"
    #include "headers/assemblyCode.hpp"
    #include "headers/symbolTableStack.hpp"
    #include "parser.h"

    int yylex();
    void yyerror(char const *s);
    // void yyerror(char const *err);
    // extern int yylex();
%}

DIGIT               [0-9]
IDENTIFIER          [a-zA-Z][a-zA-Z0-9]*
COMMENT             #.*\n
ASSIGN_OP           ":="
ADD_OP              "+"
SUB_OP              "-"
MUL_OP              "*"
DIV_OP              "/"
EQ_OP               "="
NEQ_OP              "!="
LT_OP               "<"
LTE_OP              "<="
GT_OP               ">"
GTE_OP              ">="
OPEN_PAR            "("
CLOSED_PAR          ")"
SEMICOLON           ";"
COMMA               ","

%%

PROGRAM							{ return _PROGRAM; }
BEGIN							{ return _BEGIN; }
END								{ return _END; }
FUNCTION						{ return _FUNCTION; }
READ							{ return _READ; }
WRITE							{ return _WRITE; }
IF								{ return _IF; }
ELSE							{ return _ELSE; }
FI							    { return _FI; }
FOR							    { return _FOR; }
ROF						        { return _ROF; }
RETURN							{ return _RETURN; }
INT								{ return _INT; }
VOID							{ return _VOID; }
STRING							{ return _STRING; }
FLOAT							{ return _FLOAT; }

{COMMENT}                       {}

{ASSIGN_OP}                     { return ASSIGN_OP; }
{ADD_OP}                        { return ADD_OP; }
{SUB_OP}                        { return SUB_OP; }
{MUL_OP}                        { return MUL_OP; }
{DIV_OP}                        { return DIV_OP; }
{EQ_OP}                         { return EQ_OP; }
{NEQ_OP}                        { return NEQ_OP; }
{LT_OP}                         { return LT_OP; }
{LTE_OP}                        { return LTE_OP; }
{GT_OP}                         { return GT_OP; }
{GTE_OP}                        { return GTE_OP; }
{OPEN_PAR}                      { return OPEN_PAR; }
{CLOSED_PAR}                    { return CLOSED_PAR; }
{SEMICOLON}                     { return SEMICOLON; }
{COMMA}                         { return COMMA; }


{DIGIT}+                        { yylval.intval = atoi(yytext);
                                  return INTLITERAL; }

\"[^"]*\"                       { yylval.stringval = new std::string (yytext);
                                  return STRINGLITERAL; }

{IDENTIFIER}                    { yylval.stringval = new std::string (yytext);
                                  return IDENTIFIER; }

{DIGIT}*\.{DIGIT}+              { yylval.floatval = atof(yytext);
                                  return FLOATLITERAL; }

[ \t\n]                         {}

%%

int yywrap()
{
  	return 1;
}