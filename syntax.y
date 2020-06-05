%{
#include <stdio.h>

extern int yylex();
void yyerror(const char *);
int next_line_number = 0;
void backpatch(vector<int> *,int);

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


%type <next_list> STATEMENT STATEMENT_LIST IF WHILE

%union{
    char* string_val;
    int int_val;
    float float_val;
    vector<int> *next_list;
}

%%

METHOD_BODY: STATEMENT_LIST{backpatch($1.next_list,line_number);};
STATEMENT_LIST: STATEMENT {$$.next_list = merge($1.next_list,$$.next_list);}
		| STATEMENT_LIST {backpatch($1.next_list,line_number);} STATEMENT {$$.next_list = merge($3.next_list,$$.next_list);};
STATEMENT: DECLARATION {$$.nextList = new vector<int>();}| IF{$$.nextList = $1.nextList;} | WHILE{$$.nextList = $1.nextList;}| ASSIGNMENT{$$.nextList = new vector<int>();};
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