dev: 
	@echo "Rishit Saiya\n180010027@iitdh.ac.in"

compiler: lex.yy.c parser.c main.cpp headers/ast.cpp headers/*.hpp
	@g++ -std=c++11 -w -g lex.yy.c parser.c main.cpp headers/ast.cpp -o a.out
	@chmod +x runme.sh
parser.c: parser.y
	@bison -d $^ -o parser.c
lex.yy.c: scanner.l
	@flex $^
clean:
	@rm -f lex.yy.c parser.c parser.h