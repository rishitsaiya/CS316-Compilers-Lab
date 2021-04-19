#include <iostream>
#include <string>
#include <vector>
#include "headers/ast.hpp"
#include "headers/codeObject.hpp"
#include "headers/assemblyCode.hpp"
#include "headers/symbolTableStack.hpp"
#include "parser.h"
#include <stdio.h>


extern AssemblyCode *assembly_code;
extern CodeObject *threeAC;

int yylex();
int yyparse();
void yyerror(char const *err){
    // printf("Not accepted\n");
};

int main(int argc, char* argv[]) {
	extern FILE *yyin;
    int retval;
    if (argc < 2) {
        printf("usage: ./compiler <filename> \n");
    }
    else {
        if (!(yyin = fopen(argv[1], "r"))) {
            printf("Error while opening the file.\n"); 
        }
        else {
            yyin = fopen(argv[1], "r");
            // yyset_in(yyin);
			retval = yyparse();
            // tableStack->printStack();
            fclose(yyin);

            //threeAC->print();
            std::cout << "push" << std::endl;
            std::cout << "push r0" << std::endl;
            std::cout << "push r1" << std::endl;
            std::cout << "push r2" << std::endl;
            std::cout << "push r3" << std::endl;
            std::cout << "jsr main" << std::endl;
            std::cout << "sys halt" << std::endl;
            assembly_code->generateCode(threeAC, threeAC->symbolTableStack->tables);
            assembly_code->print();
            std::cout << "end" << std::endl;
            // yylex();
        }
    }
    // if(retval == 0)
	    // printf("Accepted\n");
    
    return 0;
}