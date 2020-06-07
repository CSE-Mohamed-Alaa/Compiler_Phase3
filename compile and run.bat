del /f y.tab.c
del /f lex.yy.c
del /f y.tab.h
del /f Compiler_Phase3.exe
del /f input_code.class
flex lexical.l
bison -dy syntax.y
g++ lex.yy.c y.tab.c -o Compiler_Phase3.exe
Compiler_Phase3.exe