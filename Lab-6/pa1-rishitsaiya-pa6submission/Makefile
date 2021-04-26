dev:
	@echo "Rishit Saiya\n180010027@iitdh.ac.in"

compiler:
	@bison -d -t -o parser.cpp parser.y
	@flex scanner.l
	@g++ -std=c++11 -o parser.o -c parser.cpp
	@g++ -std=c++11 -c -o scanner.o lex.yy.c
	@g++ -std=c++11 -c -o main.o main.cpp
	@g++ -std=c++11 -o a.out main.o scanner.o parser.o headers/symbol.cpp headers/vision.cpp headers/nodeAST.cpp headers/codeOptimizer.cpp

clean:
	@rm -f *.o scanner.cpp parser.cpp lex.yy.c a.out parser.hpp