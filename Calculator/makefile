Calculator: Main.c Execute.o Parser.tab.o Lexer.o Data_File.h 
	gcc -o Calculator Main.c Execute.o Parser.tab.o Lexer.o -Wall `pkg-config --cflags --libs gtk+-3.0` -export-dynamic -lm
	
Lexer.o: lex.yy.c Parser.tab.h Data_File.h
	gcc -c lex.yy.c -o Lexer.o

Parser.tab.o: Parser.tab.c Parser.tab.h Data_File.h
	gcc -c Parser.tab.c -o Parser.tab.o 

Execute.o: Execute.c Data_File.h
	gcc -c Execute.c -o Execute.o

lex.yy.c: Lexer.l Parser.tab.h Data_File.h
	flex Lexer.l

Parser.tab.c Parser.tab.h: Parser.y Data_File.h
	bison -d Parser.y

