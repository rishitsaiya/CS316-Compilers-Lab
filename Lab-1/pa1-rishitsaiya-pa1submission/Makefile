dev: 
	@echo "Rishit Saiya\n180010027@iitdh.ac.in"

# Since the command was also getting printed when I execute `make dev`, I searched upon and got this for fix:
# https://stackoverflow.com/questions/3707517/make-file-echo-displaying-path-string

compiler: lex.yy.c
	@g++ $< -o compiler
lex.yy.c: scanner.l
	@flex $^

clean: lex.yy.c
	@rm lex.yy.c