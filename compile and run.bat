flex lexical.l
bison -dy syntax.y
g++ lex.yy.c y.tab.c -o Compiler_Phase3.exe
Compiler_Phase3.exe