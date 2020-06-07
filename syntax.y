%{

#include <bits/stdc++.h>
#include <unistd.h>
#include <string>

using namespace std;

#define INT 0
#define FLOAT 1

extern  FILE *yyin;
int line_address = 0;
int local_var_index = 1;
vector<string> byte_code;

// pair <type,index in variable array>
map<string, pair<int, int> > symbol_table;


extern int yylex();
void yyerror(const char *);
void back_patch(vector<int> *,int);
void add_to_symbol_table(string, int);
vector<int> * merge(vector<int> *, vector<int> *);
void mul_op(string,int);
void add_op(string op,int type);
void assign_op(string id_name,int assigned_type);
void rel_op(int, string, int);
string get_opposite_op(string op);
void sign_op(string op,int type);
int load_id_into_stack(string s);


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


%type <list> STATEMENT STATEMENT_LIST IF WHILE BOOL_EXPRESSION
%type <int_val> PRIMITIVE_TYPE FACTOR TERM SIMPLE_EXPRESSION IF_END LOOP_BEGIN
%union{
    char* string_val;
    int int_val;
    float float_val;
    vector<int> *list;
}

%%

METHOD_BODY: STATEMENT_LIST{back_patch($1,line_address);};
STATEMENT_LIST: STATEMENT {$$ = merge($1,$$);}
		| STATEMENT_LIST {back_patch($1,line_address);} STATEMENT {$$ = merge($3,$$);};
STATEMENT: DECLARATION {$$ = new vector<int>();}| IF{$$ = $1;} | WHILE{$$ = $1;}| ASSIGNMENT{$$ = new vector<int>();};
DECLARATION: PRIMITIVE_TYPE id 	{string s($2); add_to_symbol_table(s, $1);} semicolon;
PRIMITIVE_TYPE: int_kw {$$ = INT;} | float_kw {$$ = FLOAT;};
IF: if_kw l_bracket BOOL_EXPRESSION r_bracket l_curly_bracket
	STATEMENT_LIST {back_patch($6,line_address); byte_code.push_back(to_string(line_address) +": goto "); line_address+=3;} IF_END
	r_curly_bracket else_kw l_curly_bracket {back_patch($3,line_address);} STATEMENT_LIST r_curly_bracket {$$ = new vector<int>(); $$->push_back($8); $$ = merge($13,$$);};
WHILE: while_kw l_bracket LOOP_BEGIN BOOL_EXPRESSION r_bracket l_curly_bracket
	STATEMENT_LIST {back_patch($7,line_address);}
	r_curly_bracket {$$ = $4; byte_code.push_back(to_string(line_address) +":goto " + std::to_string($3)); line_address+=3;};
ASSIGNMENT: id assign SIMPLE_EXPRESSION {assign_op(string($1),$3);}semicolon;
BOOL_EXPRESSION: SIMPLE_EXPRESSION relop SIMPLE_EXPRESSION {$$ = new vector<int>(); rel_op($1, string($2), $3); $$->push_back(byte_code.size() - 1);};
SIMPLE_EXPRESSION: TERM {$$ = $1;} | addop TERM {$$ = $2;sign_op(string($1),$$);}| SIMPLE_EXPRESSION addop TERM{$$ = $1 | $3;add_op(string($2),$$);};
TERM: FACTOR {$$ = $1;} | TERM mulop FACTOR {$$ = $1 | $3;mul_op(string($2),$$);};
FACTOR: id {$$ = load_id_into_stack(string($1));}
	| int_num{$$ = INT;byte_code.push_back(to_string(line_address) +":ldc " + to_string($1));line_address+=2;}
	| float_num {$$ = FLOAT;byte_code.push_back(to_string(line_address) +":ldc " + to_string($1));line_address+=2;}
	| l_bracket SIMPLE_EXPRESSION r_bracket {$$ = $2;};
IF_END: {$$ = byte_code.size() - 1;};
LOOP_BEGIN: {$$ = line_address;};
%%

void yyerror(const char *s) {
    printf("Error %s\n", s);
}


void back_patch(vector<int> *list_ptr, int address) {
    vector<int> list = *list_ptr;
    for(int i = 0 ; i < list.size() ; i++) {
        byte_code[list[i]] = byte_code[list[i]] + to_string(address);
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
            byte_code.push_back(to_string(line_address) +":iconst_0");
            line_address ++;
            byte_code.push_back(to_string(line_address) +":istore " + to_string(local_var_index));
            line_address+=2;
        } else if (id_type == FLOAT) {
            byte_code.push_back(to_string(line_address) +":fconst_0");
            line_address ++;
            byte_code.push_back(to_string(line_address) +":fstore " + to_string(local_var_index));
            line_address+=2;
        }
        symbol_table[id_name] = make_pair(id_type, local_var_index++);
    }
}

void mul_op(string op,int type){
	if(type){
		if(op == "*"){
			byte_code.push_back(to_string(line_address) +":fmul");

		}else{
			byte_code.push_back(to_string(line_address) +":fdiv");

		}
	}else{
		if(op == "*"){
                	byte_code.push_back(to_string(line_address) +":imul");
                }else{
                	byte_code.push_back(to_string(line_address) +":idiv");
                }
	}
	line_address++;
}

void add_op(string op,int type){
	if(type){
		if(op == "+"){
			byte_code.push_back(to_string(line_address) +":fadd");

		}else{
			byte_code.push_back(to_string(line_address) +":fsub");

		}
	}else{
		if(op == "+"){
                		byte_code.push_back(to_string(line_address) +":iadd");
                	}else{
                		byte_code.push_back(to_string(line_address) +":isub");
                }
	}
	line_address++;
}

void rel_op(int type1, string op, int type2){
	if (type1 == type2){
		if(type1){
			byte_code.push_back(to_string(line_address) +":fcmpl");
			line_address++;
			byte_code.push_back(to_string(line_address) +":if" + get_opposite_op(op) + " ");
			line_address+=3;
		} else {
			byte_code.push_back(to_string(line_address) +":if_icmp" + get_opposite_op(op) + " ");
			line_address+=3;
		}
	} else {
		//TODO
	}
}

string get_opposite_op(string op){
	//"=="|"!="|">"|">="|"<"|"<="
	if(op == "=="){
		return "ne";
	}else if (op == "!="){
		return "eq";
	}else if (op == ">"){
         	return "le";
        }else if (op == ">="){
                 return "lt";
        }else if (op == "<"){
                 return "ge";
        }else if (op == "<="){
                 return "gt";
        }
}
int load_id_into_stack(string id_name){
	if(symbol_table.find(id_name) == symbol_table.end()){
        	string error_message = id_name + " is not defined before";
        	yyerror(error_message.c_str());
    	}else{
    		if(symbol_table[id_name].first){
    			byte_code.push_back(to_string(line_address) +":fload " + to_string(symbol_table[id_name].second));

    		}else{
    			byte_code.push_back(to_string(line_address) +":iload " + to_string(symbol_table[id_name].second));
    		}
    		line_address+=2;
    	}
    	return symbol_table[id_name].first;
}
void sign_op(string sign,int type){
	if( sign == "-" && type ){
		byte_code.push_back(to_string(line_address) +":fneg");
	}else if (sign == "-"){
		byte_code.push_back(to_string(line_address) +":ineg");
	}
	line_address++;
}
void assign_op(string id_name,int assigned_type){
	if(symbol_table.find(id_name) == symbol_table.end()){
               	string error_message = id_name + " is not defined before";
               	yyerror(error_message.c_str());
        }else{
		if(symbol_table[id_name].first == INT && assigned_type == INT){
			byte_code.push_back(to_string(line_address) +":istore " + to_string(symbol_table[id_name].second));
			line_address+=2;
		}else if (symbol_table[id_name].first == FLOAT && assigned_type == FLOAT){
			byte_code.push_back(to_string(line_address) +":fstore " + to_string(symbol_table[id_name].second));
			line_address+=2;
		} else if (symbol_table[id_name].first == FLOAT && assigned_type == INT){
			byte_code.push_back(to_string(line_address) +":i2f");
			byte_code.push_back(to_string(line_address) +":fstore " + to_string(symbol_table[id_name].second));
                        line_address+=3;
		} else {
			string error_message ="type miss match: " + id_name + " can't be assigned to float";
			yyerror(error_message.c_str());
		}
        }
}

int main() {
	FILE *input_file = fopen("input_code.txt", "r");
	if (!input_file) {
		string error_message ="Cannot find input_code.txt";
		yyerror(error_message.c_str());
	}
	yyin  = input_file;
	yyparse();
	ofstream output_file("input_code.class");
	for ( int i = 0 ; i < byte_code.size() ; i++) {
		output_file<<byte_code[i]<<endl;
	}
	return 0;
}