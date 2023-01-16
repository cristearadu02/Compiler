%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
%}

%option noyywrap

%%
"start_program"         {return BGIN;}
"end_program"           {return END;}
"start_global_var"      {return BGIN_GLOBAL_VAR;}
"end_global_var"        {return END_GLOBAL_VAR;}
"start_functions"       {return BGIN_FUNC;}
"end_functions"         {return END_FUNC;}
"start_user_def_data"   {return BGIN_USER_DATA;}
"end_user_def_data"     {return END_USER_DATA;}

"int"|"float"|"char"|"string"|"bool"|"unsigned"  {yylval.dataType = strdup(yytext); return DATA_TYPE;}
"public class"|"private class"|"protected class" {yylval.dataType = strdup(yytext); return CLASS_TYPE;}
"class"   {return CLASS;}
"const"   {return CONST;}
"void"    {return VOID;}
"#define" {return DEF;}

"print"   {return PRINT;}
"return"  {return RETURN;}

"="       {return ASSIGN;}

"if"    {return IF;}
"else"  {return ELSE;}
"while" {return WHILE;}
"for"   {return FOR;}

"@true"     {yylval.boolVal = strdup(yytext); return BOOL_VAR;}
"@false"    {yylval.boolVal = strdup(yytext); return BOOL_VAR;}

"+" {yylval.dataType=strdup(yytext); return PLUS;}
"~" {yylval.dataType=strdup(yytext); return MINUS;}
"*" {yylval.dataType=strdup(yytext); return MUL;}
"/" {yylval.dataType=strdup(yytext); return DIV;}

"<"     {return LESS;}
"<="    {return LESSEQ;}
">"     {return GREATER;}
">="    {return GREATEREQ;}
"=="    {return EQUAL;}
"!="    {return NOTEQUAL;}

"!"     {return NEG;}
"||"    {return OR;}
"&&"    {return AND;}

"("     {return ROUND_BRACKET_OPEN;}
")"     {return ROUND_BRACKET_CLOSE;}
"{"     {return CURLY_BRACKET_OPEN;}
"}"     {return CURLY_BRACKET_CLOSE;}
"["     {return SQUARE_BRACKET_OPEN;}
"]"     {return SQUARE_BRACKET_CLOSE;}
":"     {return COLON;}
";"     {return SEMICOLON;}
","     {return COMMA;}
"."     {return DOT;}

[a-zA-Z][_a-zA-Z0-9]*                           {yylval.dataType = strdup(yytext); return VARIABLE;}
[a-zA-Z][_a-zA-Z0-9]*(\[[0-9]+\])+              {yylval.strVal = strdup(yytext); return ARRAY;}   

[0-9]+[u]                      {yylval.intVal = atoi(yytext); return UNSIGNED;}
[-]?[0-9]+                     {yylval.intVal = atoi(yytext); return INT;}
[-]?[0-9]*\.?[0-9]+            {yylval.floatVal = atof(yytext); return FLOAT;}
['][a-zA-Z0-9][']                 {yylval.charVal = yytext[1]; return CHAR;}
\"([^\\\"]|\\.)*\"             {yylval.strVal = strdup(yytext); return STRING_VALUE;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
