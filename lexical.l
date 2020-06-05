%{
	#include "y.tab.h"
	#include <string>
    #include <vector>
    using namespace std;
%}
letter  [a-zA-Z]
digit [0-9]
digits {digit}+
inum "-"?{digits}
fnum "-"?{digits}.{digits}("E"{digits}+)?
%%
"if"	{return if_kw;}
"else"	{return else_kw;}
"while"	{return while_kw;}
"int"	{return int_kw;}
"float"	{return float_kw;}
"+"|"-"	{yylval.string_val = strdup(yytext); return addop;}
"*"|"/"	{yylval.string_val = strdup(yytext); return mulop;}
{inum}	{yylval.ival = atoi(yytext); return int_num;}
{fnum}	{yylval.string_val = atof(yytext); return float_num;}
"=="|"!="|">"|">="|"<"|"<=" {yylval.aopval = strdup(yytext); return relop;}
{letter}({letter}|{digit})*	{yylval.string_val = strdup(yytext);return id;}
";" { return semicolon;}
"=" {return assign;}
"(" { return l_bracket;}
")" {return r_bracket;}
"{" {return l_curly_bracket;}
"}" {return l_curly_bracket;}
%%
int yywrap() {
   return -1;
}