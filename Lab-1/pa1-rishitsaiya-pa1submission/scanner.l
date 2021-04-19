%{
%}

KEYWORD END|FUNCTION|READ|FOR|ROF|RETURN|INT|VOID|STRING|FLOAT|PROGRAM|BEGIN|WRITE|IF|ELSE|FI
OPERATOR [:][=]|[+]|[-]|[*]|[/]|[=]|[!][=]|[<]|[>]|[(]|[)]|[,]|[<][=]|[>][=]|[;]
COMMENT [#]
DIGIT [0-9]
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
SPACE [\r\n\t ]
STRINGLITERAL ["]

%%

{COMMENT}.+\n {}

{SPACE}+ {}

{DIGIT}+ {
	printf("Token Type: INTLITERAL\nValue: %d\n", atoi(yytext));
}

{DIGIT}+"."{DIGIT}* {
	printf("Token Type: FLOATLITERAL\nValue: %s\n",yytext);
}

{STRINGLITERAL}.+{STRINGLITERAL} {
	printf("Token Type: STRINGLITERAL\nValue: %s\n",yytext);
}

{KEYWORD} {
	printf("Token Type: KEYWORD\nValue: %s\n",yytext);
}

{IDENTIFIER} {
	printf("Token Type: IDENTIFIER\nValue: %s\n",yytext);
}

{OPERATOR} {
	printf("Token Type: OPERATOR\nValue: %s\n",yytext);
}

%%

/*Reference:
https://www.gnu.org/software/bison/manual/html_node/Calc_002b_002b-Scanner.html*/

int yywrap(){
  	return 1;
}

int main(int argc, char* argv[]){
	if(argc > 1){
		FILE *filepointer = fopen(argv[1], "r");
		if(filepointer)
			yyin = filepointer;
	}
    yylex();
    return 1;
}