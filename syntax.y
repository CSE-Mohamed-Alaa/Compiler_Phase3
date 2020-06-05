%{
#include <stdio.h>

extern int yylex();
void yyerror(const char *);

%}

%code requires {
    #include <vector>
    using namespace std;
}

%start METHOD_BODY

//define tokens from lexical and its values type
%token <string_val> id relop addop mulop
%token <int_val> int_num
%token <float_val> float_num
%token int_kw float_kw if_kw else_kw while_kw
%token assign
%token l_bracket r_bracket l_curly_bracket r_curly_bracket semicolon


%union{
    char* string_val;
    int int_val;
    float float_val;
}

%%

METHOD_BODY: STATEMENT_LIST;
STATEMENT_LIST: STATEMENT | STATEMENT_LIST STATEMENT;
STATEMENT: DECLARATION | IF | WHILE | ASSIGNMENT;
DECLARATION: PRIMITIVE_TYPE id semicolon;
PRIMITIVE_TYPE: int_kw | float_kw;
IF: if_kw l_bracket BOOL_EXPRESSION r_bracket l_curly_bracket STATEMENT_LIST r_curly_bracket else_kw l_curly_bracket STATEMENT_LIST r_curly_bracket;
WHILE: while_kw l_bracket BOOL_EXPRESSION r_bracket l_curly_bracket STATEMENT_LIST r_curly_bracket;
ASSIGNMENT: id assign SIMPLE_EXPRESSION semicolon;
BOOL_EXPRESSION: SIMPLE_EXPRESSION relop SIMPLE_EXPRESSION;
SIMPLE_EXPRESSION: TERM | addop TERM | SIMPLE_EXPRESSION addop TERM;
TERM: FACTOR | TERM mulop FACTOR;
FACTOR: id | int_num | float_num | l_bracket SIMPLE_EXPRESSION r_bracket;

%%

void yyerror(const char *s) {
    printf("Syntax Error on line %s\n", s);
}

int main() {
	yyparse();
	return 0;
}