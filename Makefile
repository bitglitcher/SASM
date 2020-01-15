build: grammar scanner compile_scanner preprocessor compile copy_bin

grammar: grammar.y
	bison -y -d grammar.y
scanner: lexer.l
	flex lexer.l
compile_scanner: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c -c
preprocessor: preprocessor.c preprocessor.h
	gcc preprocessor.c preprocessor.h -c
compile: main.c y.tab.o lex.yy.o libs/vector.c libs/t_buffer.c libs/s_buffer.c preprocessor.o 
	gcc main.c y.tab.o lex.yy.o libs/vector.c libs/t_buffer.c libs/s_buffer.c preprocessor.o  -lm -o dasm
copy_bin: 
	cp dasm bin_out/
