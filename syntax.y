%{

#include <bits/stdc++.h>
#include <unistd.h>

using namespace std;

#define INT 0
#define FLOAT 1



map<string, pair<int, int>> symbol_table;

int line_address = 0;
int local_var_index = 1;
vector<string> byte_code;


extern int yylex();
void yyerror(const char *);
void back_patch(vector<int> *,int);
add_to_symbol_table(string, int);
vector<int> * merge(vector<int> *, vector<int> *);


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
%type <int_val> PRIMITIVE_TYPE

%union{
    char* string_val;
    int int_val;
    float float_val;
    vector<int> *next_list;
}

%%

METHOD_BODY: STATEMENT_LIST{backpatch($1.next_list,line_address);};
STATEMENT_LIST: STATEMENT {$$.next_list = merge($1.next_list,$$.next_list);}
		| STATEMENT_LIST {backpatch($1.next_list,line_address);} STATEMENT {$$.next_list = merge($3.next_list,$$.next_list);};
STATEMENT: DECLARATION {$$.nextList = new vector<int>();}| IF{$$.nextList = $1.nextList;} | WHILE{$$.nextList = $1.nextList;}| ASSIGNMENT{$$.nextList = new vector<int>();};
DECLARATION: PRIMITIVE_TYPE id 	{string s($2); add_to_symbol_table(s, $1);} semicolon;
PRIMITIVE_TYPE: int_kw {$$ = INT} | float_kw {$$ = FLOAT};
IF: if_kw l_bracket BOOL_EXPRESSION r_bracket l_curly_bracket STATEMENT_LIST r_curly_bracket else_kw l_curly_bracket STATEMENT_LIST r_curly_bracket;
WHILE: while_kw l_bracket BOOL_EXPRESSION r_bracket l_curly_bracket STATEMENT_LIST r_curly_bracket;
ASSIGNMENT: id assign SIMPLE_EXPRESSION semicolon;
BOOL_EXPRESSION: SIMPLE_EXPRESSION relop SIMPLE_EXPRESSION;
SIMPLE_EXPRESSION: TERM | addop TERM | SIMPLE_EXPRESSION addop TERM;
TERM: FACTOR | TERM mulop FACTOR;
FACTOR: id | int_num | float_num | l_bracket SIMPLE_EXPRESSION r_bracket;

%%

void yyerror(const char *s) {
    printf("Error %s\n", s);
}


void back_patch(vector<int> *list_ptr, int address) {
    vector<int> list = *list_ptr;
    for(int i = 0 ; i < lists.size() ; i++) {
        byte_code[list[i]] = byte_code[list[i]] + to_string(address));
    }
}


//TODO check if lists are empty
vector<int> * merge(vector<int> *list1, vector<int> *list2) {
    vector<int> *list = new vector<int> (*list1);
    list->insert(list->end(), list2->begin(), list2->end());
    return list;
}




void add_to_symbol_table(string id_name, int id_type){
    if(symbol_table.find(id_name) != symbol_table.end()){
        string error_message = "multiple definition of the same variable: " + id_name;
        printf("(TODO OUR TEST ERROR) Error %s\n", error_message.c_str());
        yyerror(error_message.c_str());
    }else{
        if(id_type == INT) {
            byte_code.push_back("iconst_0");
            byte_code.push_back("istore " + to_string(local_var_index));
        } else if (id_type == FLOAT) {
            byte_code.push_back("fconst_0");
            byte_code.push_back("fstore " + to_string(local_var_index));
        }
        line_address += 3;
        symbol_table[id_name] = make_pair(id_type, local_var_index++);
    }
}

int main() {
	yyparse();
	return 0;
}