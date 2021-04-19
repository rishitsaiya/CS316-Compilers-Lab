// Acknowledgements: https://github.com/aswanthpp/Compiler-Design
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include "microParser.h"

int yyparse();
int yylex(); 
extern FILE* yyin;

// yerror function
void yyerror(const char *s){
  printf("");
}

// main function
int main(int argc, char* argv[]){
	if(argc > 1){
		FILE *filep = fopen(argv[1], "r");
		if(filep)
			yyin = filep;
	}
	
    if (yyparse() == 0)
        printf("");
}