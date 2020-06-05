%{
	#include "y.tab.h"
	#include <string.h>
    void showError();

%}
letter [a-zA-Z]
digit [0-9]
digits {digit}+
inum {digits}
fnum {digits}([.]{digit}*)?|[.]{digits}
%%
"if"	{return if_kw;}
"else"	{return else_kw;}
"while"	{return while_kw;}
"int"	{return int_kw;}
"float"	{return float_kw;}
"+"|"-"	{yylval.string_val = strdup(yytext); return addop;}
"*"|"/"	{yylval.string_val = strdup(yytext); return mulop;}
{inum}	{yylval.int_val = atoi(yytext); return int_num;}
{fnum}	{yylval.float_val = atof(yytext); return float_num;}
"=="|"!="|">"|">="|"<"|"<=" {yylval.string_val = strdup(yytext); return relop;}
{letter}({letter}|{digit})*	{yylval.string_val = strdup(yytext); return id;}
";" {return semicolon;}
"=" {return assign;}
"(" {return l_bracket;}
")" {return r_bracket;}
"{" {return l_curly_bracket;}
"}" {return r_curly_bracket;}
.   {showError();}
%%


void showError(){
    printf("Other input");
}
int yywrap() {
   return -1;
}