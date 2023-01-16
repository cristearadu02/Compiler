%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include "Functions.h"
extern void yyerror();
extern int yylex();
extern char* yytext;
extern int yylineno;
extern FILE *yyin;
char scope[100]="global";
char call_param[200]="";
char existing_params[300]="";
char actually_params[300]="";
char typeOf_params[300][300];
int index_typeOf=0;

int tip_expr;

struct fun1
{
    char type1[100];
    char name1[100];

}functions1[1000];
int index_fun1 = 0;
char params[200][200];
int index_params = 0;

%}

%union{
    char* str;
    char* dataType;
	  int intVal;
    float floatVal;
	  char charVal;
	  char* strVal;
    unsigned unsignedVal;
    char* boolVal;
    struct node* node;
}

%token BGIN END BGIN_GLOBAL_VAR END_GLOBAL_VAR BGIN_FUNC END_FUNC BGIN_USER_DATA END_USER_DATA CONST
%type <node> operand_p
%type <node> function_call
%type <node> function_call_inside
%type <node> list_p
%type <node> list_parameters
%type <node> list_expr_1
%type <node> operand_expr

%token IF
%token ELSE
%token WHILE
%token FOR

%token <dataType> DATA_TYPE
%token <intVal> INT
%token <floatVal> FLOAT
%token <charVal> CHAR 
%token <strVal> STRING_VALUE
%token <boolVal> BOOL_VAR
%token <unsignedVal> UNSIGNED 
%token <str> VARIABLE
%token <str> ARRAY
%token DEF
%token <dataType> CLASS_TYPE
%token CLASS
%token VOID
%token PRINT
%token RETURN

%token LESS
%token LESSEQ
%token GREATER
%token GREATEREQ
%token EQUAL
%token NOTEQUAL
%token NEG
%token ASSIGN
%token OR
%token AND

%token ROUND_BRACKET_OPEN
%token ROUND_BRACKET_CLOSE
%token CURLY_BRACKET_OPEN
%token CURLY_BRACKET_CLOSE
%token SQUARE_BRACKET_OPEN
%token SQUARE_BRACKET_CLOSE
%token COLON
%token SEMICOLON
%token COMMA
%token DOT


%token <dataType> PLUS MINUS MUL DIV
%start program

%%
// |------------> SECTIUNI PROGRAM <------------|
program : global_declarations functions user_data main {printf("Syntactically correct program...yaaaay :D\n");}
        ;

// |-----------> DECLARATII GLOBALE <-----------|
global_declarations : BGIN_GLOBAL_VAR CURLY_BRACKET_OPEN declarations CURLY_BRACKET_CLOSE END_GLOBAL_VAR
                        {
                            add_special_functions();
                            strcpy(scope,"in_function");
                        }
                    ;

// |-----------> DECLARATII FUNCTII <-----------|
functions : BGIN_FUNC CURLY_BRACKET_OPEN list_functions CURLY_BRACKET_CLOSE END_FUNC
            {
                strcpy(scope,"in_class");
            }
          ;

// |----------------> USER DATA <---------------|
user_data : BGIN_USER_DATA CURLY_BRACKET_OPEN defines_list classes_list CURLY_BRACKET_CLOSE END_USER_DATA
            {
                strcpy(scope,"main");
            }
          ;

// |------------------> MAIN <------------------|
main : BGIN CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE END
     ;

// |---------------> DECLARATII <---------------|
declarations : decl
             | declarations decl
             ;

// |---------------> DECLARATIE <---------------|
decl : CONST DATA_TYPE VARIABLE ASSIGN INT SEMICOLON
       {
        if(strcmp($2, "int") == 0)
        {
          if(is_duplicate($3) == 0)
            {
            char aux[10]="";
            itoa($5,aux,10);
            char auxx[25] = "const ";
            strcat(auxx, $2);
            add_new_var(auxx, $3, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
        }
        else
        {
          yyerror("Assignement impossible. Variable doesn't have type int");
          return 0;
        }
       }
     | CONST DATA_TYPE VARIABLE ASSIGN FLOAT SEMICOLON
       {
        if(strcmp($2, "float") == 0)
        {
          if(is_duplicate($3) == 0)
            {
            char aux[10]="";
            ftoa($5,aux,2);
            char auxx[25] = "const ";
            strcat(auxx, $2);
            add_new_var(auxx, $3, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
        }
        else
        {
          yyerror("Assignement impossible. Variable doesn't have type float");
          return 0;
        }
       }
     | CONST DATA_TYPE VARIABLE ASSIGN UNSIGNED SEMICOLON
       {
        if(strcmp($2, "unsigned") == 0)
        {
          if(is_duplicate($3) == 0)
            {
            char aux[10]="";
            itoa($5,aux,10);
            char auxx[25] = "const ";
            strcat(auxx, $2);
            add_new_var(auxx, $3, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
        }
        else
        {
            yyerror("Assignement impossible. Variable doesn't have type unsigned");
            return 0;
        }
       }
     | CONST DATA_TYPE VARIABLE ASSIGN CHAR SEMICOLON
       { 
        if(strcmp($2, "char") == 0) 
        {
          if(is_duplicate($3) == 0)
            {
            char aux[10]="'";
            aux[1]=$5;
            strcat(aux,"'");
            aux[3]='\0';
            char auxx[25] = "const ";
            strcat(auxx, $2);
            add_new_var(auxx, $3, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
        }
        else
        {
            yyerror("Assignement impossible. Variable doesn't have type char");
            return 0;
        }
        }
     | CONST DATA_TYPE VARIABLE ASSIGN STRING_VALUE SEMICOLON
        {
          if(strcmp($2, "string") == 0)
          {
            if(is_duplicate($3) == 0)
            { 
            char auxx[25] = "const ";
            strcat(auxx, $2);
            add_new_var(auxx, $3, $5, scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type string");
            return 0;
          }
        }
     | CONST DATA_TYPE VARIABLE SEMICOLON {yyerror("Constant variable must be assigned with value"); return 0;}
     | DATA_TYPE VARIABLE SEMICOLON 
       {
        if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
        {
          add_new_var($1, $2, "NULL", scope);
          write_var();
        }
        else
          {
            return 0;
          }
       }                                  
     | DATA_TYPE VARIABLE ASSIGN INT SEMICOLON 
        { 
          if(strcmp($1, "int") == 0)
          {
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            {
            char aux[10]="";
            itoa($4,aux,10);
            add_new_var($1, $2, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type int");
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ASSIGN FLOAT SEMICOLON
        { 
          if(strcmp($1, "float") == 0)
          {
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            {
            char aux[10]="";
            ftoa($4,aux,2);
            add_new_var($1, $2, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type float");
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ASSIGN UNSIGNED SEMICOLON
        { 
          if(strcmp($1, "unsigned") == 0)
          {
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            {
            char aux[10]="";
            itoa($4,aux,10);
            add_new_var($1, $2, aux, scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type unsigned");
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ASSIGN CHAR SEMICOLON
       {  
        if(strcmp($1, "char") == 0)
        {
        if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
          {
          char aux[10]="'";
          aux[1]=$4;
          strcat(aux,"'");
          aux[3]='\0';
          add_new_var($1, $2, aux, scope);
          write_var();
          }
          else
          {
            return 0;
          }
        }
        else 
        {
            yyerror("Assignement impossible. Variable doesn't have type char");
            return 0;
        }
       }
     | DATA_TYPE VARIABLE ASSIGN STRING_VALUE SEMICOLON
        {
          if(strcmp($1, "string") == 0)
          { 
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            { 
            add_new_var($1, $2, $4, scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type string");
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ASSIGN BOOL_VAR SEMICOLON
        {
          if(strcmp($1, "bool") == 0)
          { 
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            { 
            if(strcmp($4,"@false")==0)
            add_new_var($1, $2, "false", scope);
              else
            add_new_var($1, $2, "true", scope);
            write_var();
            }
            else
            {
              return 0;
            }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type string");
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ASSIGN VARIABLE SEMICOLON
        {
          if(check_if_variable_exists($4) == 1 && is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
            {
              if((get_type($4)==0 && strcmp($1,"int")==0) ||  (get_type($4)==1 && strcmp($1,"float")==0) || (get_type($4)==2 && strcmp($1,"unsigned")==0) || (get_type($4)==3 && strcmp($1,"char")==0) 
                  || (get_type($4)==4 && strcmp($1,"string")==0))
                  {
                    add_new_var($1, $2, get_value($4),scope);
                  }
              else 
              {
                yyerror("Assignement impossible. Variables have different types");
                return 0;
              }
            }
            else 
            {
              char err[100]="Variable '";
              strcat(err, $2);
              strcat(err, "' declared more than once");
              yyerror(err);
              return 0;
            }
        } 
     | DATA_TYPE VARIABLE ASSIGN ARRAY SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $4);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
              {
                if((get_type(aux)==0 && strcmp($1,"int")==0) ||  (get_type(aux)==1 && strcmp($1,"float")==0) || (get_type(aux)==2 && strcmp($1,"unsigned")==0) || (get_type(aux)==3 && strcmp($1,"char")==0) 
                  || (get_type(aux)==4 && strcmp($1,"string")==0))
                {
                  if(check_if_variable_exists(aux) == 1)
                  {
                   add_new_var($1, $2, get_array_value(ind, nr),scope);
                    write_var();
                  }
                  else 
                  {
                    return 0;
                  }
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have the same type");
                  return 0;
                }
              }
              else
              {
                return 0;
              }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | VARIABLE ASSIGN INT SEMICOLON                                 /*initializare variabila*/
        {
          if(get_type($1)==0)
          {
          if(check_if_variable_exists($1) == 1)
          {
            char aux[10]="";
            itoa($3,aux,10);
            update_value($1, aux);
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type int");
            return 0;
          }
        }
     | VARIABLE ASSIGN FLOAT SEMICOLON                                 /*initializare variabila*/
        {
          if(get_type($1)==1)
          {
          if(check_if_variable_exists($1) == 1)
          {
            char aux[10]="";
            ftoa($3,aux,2);
            update_value($1, aux);
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type float");
            return 0;
          }
        }
     | VARIABLE ASSIGN UNSIGNED SEMICOLON                                 /*initializare variabila*/
        {
          if(get_type($1) == 2)
          {
            if(check_if_variable_exists($1) == 1)
          {
            char aux[10]="";
            itoa($3,aux,10);
            update_value($1, aux);
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type unsigned");
            return 0;
          }
        }
     | VARIABLE ASSIGN CHAR SEMICOLON                                 /*initializare variabila*/
        {
          if(get_type($1)==3)
          {
          if(check_if_variable_exists($1) == 1)
          {
            char aux[10]="'";
            aux[1]=$3;
            strcat(aux,"'");
            aux[3]='\0';
            update_value($1, aux);
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type char");
            return 0;
          }
        }
     | VARIABLE ASSIGN STRING_VALUE SEMICOLON                                 /*initializare variabila*/
        {
          if(get_type($1) == 4)
          {
          if(check_if_variable_exists($1) == 1)
          {
            update_value($1, $3);
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type string");
            return 0;
          }
        }
     | VARIABLE ASSIGN BOOL_VAR SEMICOLON                                 
        {
          if(get_type($1) == 5)
          {
          if(check_if_variable_exists($1) == 1)
          {
            if(strcmp($3,"@false") == 0)
            update_value($1, "false");
            else
            update_value($1, "true");
          }
          else 
          {
            return 0;
          }
          }
          else
          {
            yyerror("Assignement impossible. Variable doesn't have type bool");
            return 0;
          }
        }
     | VARIABLE ASSIGN VARIABLE SEMICOLON
        {
          if(check_if_variable_exists($1) == 1 && check_if_variable_exists($3) == 1)
          {
            if(get_type($1) <= 5)
            {
              if((get_type($1) == get_type($3)) || (get_type($1) == get_type($3) - 6))
              {
                update_value($1, get_value($3));
              }
              else 
              {
                yyerror("Assignement impossible. Variables have different types");
                return 0;
              }
            }
            else
            {
              yyerror("You can't assign a value to a variable of type const after declaration");
              return 0;
            }
          }
          else 
          {
            return 0;
          }
        }
     | VARIABLE ASSIGN ARRAY SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $3);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(check_if_variable_exists($1) == 1)
              {
                if(get_type(aux)==get_type($1))
                {
                  if(check_if_variable_exists(aux) == 1)
                  {
                    update_value($1, get_array_value(ind, nr));
                    write_var();
                  }
                  else 
                  {
                    return 0;
                  }
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type string");
                  return 0;
                }
              }
              else
              {
                return 0;
              }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | DATA_TYPE ARRAY SEMICOLON                                         /*array*/
       {
          if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $2);
          int i = 0;
          while(aux[i]!='[')
           i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          add_new_arr($1, aux, scope, nr);
          write_var();
        }
        else
          {
            return 0;
          }
       }
      | ARRAY ASSIGN INT SEMICOLON
        {
          char aux[100]="",number[10]="";
              strcpy(aux, $1);
              int i = 0;
              while(aux[i]!='[')
              i++;
              strcpy(number, aux+i+1);
              number[strlen(number)-1] = '\0';
              aux[i]='\0';
              int nr = atoi(number);
              int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(get_type(aux)==0 || get_type(aux)==6)
            {
              if(check_if_variable_exists(aux) == 1)
              {
                
                char auxx[10]="";
                itoa($3,auxx,10);
                add_arr_value(ind,nr,auxx);
                write_var();
              }
              else 
              {
                return 0;
              }
            }
            else
            {
              yyerror("Assignement impossible. Variable doesn't have type int");
              return 0;
            }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | ARRAY ASSIGN FLOAT SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(get_type(aux)==1 || get_type(aux)==7)
            {
              if(check_if_variable_exists(aux) == 1)
              {
                
                char auxx[10]="";
                ftoa($3,auxx,2);
                add_arr_value(ind,nr,auxx);
                write_var();
              }
              else 
              {
                return 0;
              }
            }
            else
            {
              yyerror("Assignement impossible. Variable doesn't have type float");
              return 0;
            }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | ARRAY ASSIGN UNSIGNED SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(get_type(aux)==2 || get_type(aux)==8)
            {
              if(check_if_variable_exists(aux) == 1)
              {
                
                char auxx[10]="";
                itoa($3,auxx,10);
                add_arr_value(ind,nr,auxx);
                write_var();
              }
              else 
              {
                return 0;
              }
            }
            else
            {
              yyerror("Assignement impossible. Variable doesn't have type unsigned");
              return 0;
            }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
      | ARRAY ASSIGN CHAR SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(get_type(aux)==3 || get_type(aux)==9)
            {
              if(check_if_variable_exists(aux) == 1)
              {
                char auxx[10]="'";
                auxx[1]=$3;
                strcat(auxx,"'");
                auxx[3]='\0';
                add_arr_value(ind,nr,auxx);
                write_var();
              }
              else 
              {
                return 0;
              }
            }
            else
            {
              yyerror("Assignement impossible. Variable doesn't have type char");
              return 0;
            }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | ARRAY ASSIGN STRING_VALUE SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(get_type(aux)==4 || get_type(aux)==10)
            {
              if(check_if_variable_exists(aux) == 1)
              {
                add_arr_value(ind,nr,$3);
                write_var();
              }
              else 
              {
                return 0;
              }
            }
            else
            {
              yyerror("Assignement impossible. Variable doesn't have type string");
              return 0;
            }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | ARRAY ASSIGN VARIABLE SEMICOLON
        {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
          i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >=0 && nr < max_arr_index(ind))
          {
            if(check_if_variable_exists($3) == 1)
              {
                if(get_type(aux)==get_type($3) || get_type(aux)==get_type($3)-6)
                {
                  if(check_if_variable_exists(aux) == 1)
                  {
                    add_arr_value(ind,nr,get_value($3));
                    write_var();
                  }
                  else 
                  {
                    return 0;
                  }
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type string");
                  return 0;
                }
              }
              else
              {
                return 0;
              }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
        }
     | CLASS VARIABLE VARIABLE SEMICOLON                                 /*instantiere clasa*/
       {
          if(check_if_variable_exists($2) == 0)
            {
              return 0;
            }
            else
            {
              char class_name[20]="class ";
              strcat(class_name, $2);
              add_new_var(class_name, $3, "NULL", scope);
            }
       }      
     | VARIABLE DOT function_call                                        /*accesare metode clasa*/
       {
        if(check_if_variable_exists($1) == 0)
          {
              return 0;
          }
          else
          {
            if(get_type($1) !=11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
          }
       }
     | VARIABLE DOT VARIABLE ASSIGN INT SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 0)
                {
                char aux[10]="";
                itoa($5,aux,10);
                update_value($3, aux);
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type int");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
     | VARIABLE DOT VARIABLE ASSIGN FLOAT SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 1)
                {
                char aux[10]="";
                ftoa($5,aux,2);
                update_value($3, aux);
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type float");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
     | VARIABLE DOT VARIABLE ASSIGN UNSIGNED SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 2)
                {
                char aux[10]="";
                itoa($5,aux,10);
                update_value($3, aux);
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type unsigned");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
     | VARIABLE DOT VARIABLE ASSIGN CHAR SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 3)
                {
                char aux[10]="'";
                aux[1]=$5;
                strcat(aux,"'");
                aux[3]='\0';
                update_value($3, aux);
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type char");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
     | VARIABLE DOT VARIABLE ASSIGN STRING_VALUE SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 4)
                {
                  update_value($3, $5);
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type string");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
      | VARIABLE DOT VARIABLE ASSIGN BOOL_VAR SEMICOLON                            /*accesare camp clasa*/
        {
          if(check_if_variable_exists($1)==1 && check_if_variable_exists($3)==1)
          {
            if(get_type($1) != 11 )
              {
                 yyerror("This variable is not an instance of a class");
                 return 0; 
              }
              else
              {
                if(get_type($3) == 5)
                {
                  if(strcmp($5,"@false") == 0)
                  update_value($3, "false");
                  else
                  update_value($3, "true");
                }
                else
                {
                  yyerror("Assignement impossible. Variable doesn't have type bool");
                  return 0;
                }
              }
          }
          else
          {
            return 0;
          }
        }
     ;


// |---------> INSTRUCTIUNI GENERALE <----------|
list : statement 
     | list statement 
     ;

// |--------------> INSTRUCTIUNE <--------------|
statement : decl 
          | list_operations
          | function_call
          | WHILE ROUND_BRACKET_OPEN condition_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
          | FOR ROUND_BRACKET_OPEN declarations condition_list SEMICOLON list_operations ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
          | IF ROUND_BRACKET_OPEN condition_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
          | IF ROUND_BRACKET_OPEN condition_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE ELSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
          | PRINT ROUND_BRACKET_OPEN list_print ROUND_BRACKET_CLOSE SEMICOLON
          | RETURN operand SEMICOLON
          ;

// |-----------------> PRINT <-----------------|
list_print :  STRING_VALUE
           | CHAR
           | function_call_inside
           | list_expr
           ;

// |--------------> ASIGN OP MATE <-------------|
list_operations : VARIABLE ASSIGN list_expr_1 SEMICOLON
                    {
                      if(check_if_variable_exists($1)==1)
                        {
                          int value = evalAST((struct node*)$3);
                          char aux[20]="";
                          itoa(value, aux, 10);
                          update_value($1, aux);
                          //printf("---%s---", aux);
                          if(get_type($1) <= 5)
                            tip_expr = get_type($1);
                          else
                          {
                            yyerror("You can't assign a value to a variable of type const after declaration");
                            return 0;
                          }
                        }
                      else
                       {
                        return 0;
                       }
                    }
                ;

// |----------> OPERATIE MATEMATICA <-----------|
 list_expr : operand
           | list_expr PLUS list_expr
           | list_expr MINUS list_expr
           | list_expr MUL list_expr
           | list_expr DIV list_expr
           | ROUND_BRACKET_OPEN list_expr ROUND_BRACKET_CLOSE
           ;

list_expr_1 : operand_expr
           | list_expr_1 PLUS list_expr_1
              {
                struct node* node = (struct node*)malloc(sizeof(struct node));
                strcpy(node->value.operator, $2);
                $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
              }
           | list_expr_1 MINUS list_expr_1
              {
                struct node* node = (struct node*)malloc(sizeof(struct node));
                strcpy(node->value.operator, $2);
                $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
              }
           | list_expr_1 MUL list_expr_1
              {
                struct node* node = (struct node*)malloc(sizeof(struct node));
                strcpy(node->value.operator, $2);
                $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
              }
           | list_expr_1 DIV list_expr_1
              {
                struct node* node = (struct node*)malloc(sizeof(struct node));
                strcpy(node->value.operator, $2);
                $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
              }
           | ROUND_BRACKET_OPEN list_expr_1 ROUND_BRACKET_CLOSE {$$ = $2;}
           ;

// |------------> CONDITII TESTARE <------------|
condition_list : condition
               | NEG condition
               | condition_list AND condition
               | condition_list OR condition
               | condition_list AND NEG condition 
               | condition_list OR NEG operand
               | ROUND_BRACKET_OPEN condition_list AND condition ROUND_BRACKET_CLOSE
               | ROUND_BRACKET_OPEN condition_list OR condition ROUND_BRACKET_CLOSE
               | ROUND_BRACKET_OPEN condition_list AND NEG condition ROUND_BRACKET_CLOSE
               | ROUND_BRACKET_OPEN condition_list OR NEG operand ROUND_BRACKET_CLOSE
               ;

// |-------------> CONDITII LOGICE <------------|
condition : list_expr
          | list_expr GREATER list_expr
          | list_expr GREATEREQ list_expr
          | list_expr LESS list_expr
          | list_expr LESSEQ list_expr
          | list_expr EQUAL list_expr 
          | list_expr NOTEQUAL list_expr
          ;

// |------------> OPERANZI CONDITII <-----------|
operand : VARIABLE
          {
            if(check_if_variable_exists($1) == 0)
              return 0;
          }
        | UNSIGNED
        | FLOAT
        | INT
        | BOOL_VAR
        | ARRAY
          {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
            i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >= 0 && nr < max_arr_index(ind))
          {
            if(check_if_variable_exists(aux) == 0)
            {
              return 0;
            }
        
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
          }
        | function_call_inside
        ;

operand_expr : VARIABLE
          {
            if(check_if_variable_exists($1) == 0)
              return 0;
            else
            {
              if (get_type($1) != tip_expr)
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }
              switch (get_type($1)) 
              {
                case 0: {
                    strcat(actually_params,"int ");
                    strcat(typeOf_params[index_typeOf], "int");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                    break;
                }
                case 1: {
                    strcat(actually_params,"float ");
                    strcat(typeOf_params[index_typeOf], "float");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                    break;
                } 
                case 2: {
                    strcat(actually_params,"unsigned ");
                    strcat(typeOf_params[index_typeOf], "unsigned");
                    index_typeOf++;
                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                    break;
                } 
                case 3: {
                    strcat(actually_params,"char ");
                    strcat(typeOf_params[index_typeOf], "char");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 4: {
                    strcat(actually_params,"string ");
                    strcat(typeOf_params[index_typeOf], "string");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 5: {
                    strcat(actually_params,"bool ");
                    strcat(typeOf_params[index_typeOf], "bool");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 6: {
                    strcat(actually_params,"int ");
                    strcat(typeOf_params[index_typeOf], "int");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                    break;
                } 
                case 7: {
                    strcat(actually_params,"float ");
                    strcat(typeOf_params[index_typeOf], "float");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                    break;
                } 
                case 8: {
                    strcat(actually_params,"unsigned ");
                    strcat(typeOf_params[index_typeOf], "unsigned");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value($1));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                    break;
                } 
                case 9: {
                    strcat(actually_params,"char ");
                    strcat(typeOf_params[index_typeOf], "char");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                case 10: {
                    strcat(actually_params,"string ");
                    strcat(typeOf_params[index_typeOf], "string");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                case 11: {
                    strcat(actually_params,"class ");
                    strcat(typeOf_params[index_typeOf], "class");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                default:
                {
                  strcat(actually_params,"default ");
                  strcat(typeOf_params[index_typeOf], "default");
                  index_typeOf++;

                  struct node* node = (struct node*)malloc(sizeof(struct node));
                  node->value.number = 0;
                  $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                  break;
                }    
              }
            }
          }
        | UNSIGNED
          {
            if (tip_expr != 2)
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }

            struct node* node = (struct node*)malloc(sizeof(struct node));
            node->value.number = $1;
            $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
          }
        | FLOAT
          {
            if (tip_expr != 1)
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }

            struct node* node = (struct node*)malloc(sizeof(struct node));
            node->value.number = $1;
            $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
          }
        | INT
          {
            if (tip_expr != 0)
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }

            struct node* node = (struct node*)malloc(sizeof(struct node));
            node->value.number = $1;
            $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
          }
        | BOOL_VAR
          {
            if (tip_expr != 5) 
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }

            struct node* node = (struct node*)malloc(sizeof(struct node));
            node->value.number = 0;
            $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
          }
        | ARRAY
          {
          char aux[100]="",number[10]="";
          strcpy(aux, $1);
          int i = 0;
          while(aux[i]!='[')
            i++;
          strcpy(number, aux+i+1);
          number[strlen(number)-1] = '\0';
          aux[i]='\0';
          int nr = atoi(number);
          int ind = index_arr_return(aux);
          if(nr >= 0 && nr < max_arr_index(ind))
          {
            if(check_if_variable_exists(aux) == 0)
            {
              return 0;
            }
            if (get_type(aux) != tip_expr)
              {
                yyerror("All variables in the right side must have the same type as the variable in the left side");
                return 0;
              }

              switch (get_type(aux)) 
              {
                case 0: {
                    strcat(actually_params,"int ");
                    strcat(typeOf_params[index_typeOf], "int");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                    break;
                }
                case 1: {
                    strcat(actually_params,"float ");
                    strcat(typeOf_params[index_typeOf], "float");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                    break;
                } 
                case 2: {
                    strcat(actually_params,"unsigned ");
                    strcat(typeOf_params[index_typeOf], "unsigned");
                    index_typeOf++;
                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                    break;
                } 
                case 3: {
                    strcat(actually_params,"char ");
                    strcat(typeOf_params[index_typeOf], "char");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 4: {
                    strcat(actually_params,"string ");
                    strcat(typeOf_params[index_typeOf], "string");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 5: {
                    strcat(actually_params,"bool ");
                    strcat(typeOf_params[index_typeOf], "bool");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                } 
                case 6: {
                    strcat(actually_params,"int ");
                    strcat(typeOf_params[index_typeOf], "int");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                    break;
                } 
                case 7: {
                    strcat(actually_params,"float ");
                    strcat(typeOf_params[index_typeOf], "float");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                    break;
                } 
                case 8: {
                    strcat(actually_params,"unsigned ");
                    strcat(typeOf_params[index_typeOf], "unsigned");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    char valoare[20] = "";
                    strcpy(valoare, get_value(aux));

                    node->value.number = atoi(valoare);
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                    break;
                } 
                case 9: {
                    strcat(actually_params,"char ");
                    strcat(typeOf_params[index_typeOf], "char");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                case 10: {
                    strcat(actually_params,"string ");
                    strcat(typeOf_params[index_typeOf], "string");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                case 11: {
                    strcat(actually_params,"class ");
                    strcat(typeOf_params[index_typeOf], "class");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                }
                default:
                {
                  strcat(actually_params,"default ");
                  strcat(typeOf_params[index_typeOf], "default");
                  index_typeOf++;

                  struct node* node = (struct node*)malloc(sizeof(struct node));
                  node->value.number = 0;
                  $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                  break;
                }    
              }
          }
          else
          {
            yyerror("Position out of range");
            return 0;
          }
          }
        | function_call_inside
        ;


// |--------------> APEL FUNCTIE <--------------|
function_call : VARIABLE ROUND_BRACKET_OPEN list_parameters ROUND_BRACKET_CLOSE SEMICOLON
                {
                   if(check_if_function_exists($1) == 0)
                      return 0;
                    else if(strcmp(get_function_type($1), "specialTypeOf") != 0 && strcmp(get_function_type($1), "specialEval") != 0)
                    {
                       strcpy(existing_params,get_parameters($1));
                       if(strcmp(existing_params,actually_params)!=0)
                         {
                          //printf("-%s--%s--%s--%d-",existing_params,actually_params, $1, yylineno);
                          yyerror("The parameters of the function call don't have the types from the function definition");
                          return 0;
                         }
                       index_typeOf = 0;
                       bzero(actually_params,300);   
                    }
                    else
                    {
                        if(strcmp(get_function_type($1), "specialTypeOf") == 0)
                        {
                          for(int i=0; i<index_typeOf; i++)
                            {
                              //printf("->%s<-",typeOf_params[i]);
                              if(strcmp(typeOf_params[0], typeOf_params[i])!=0)
                              {
                                yyerror("Parameters in TypeOf must have the same type");
                                return 0;
                              }
                            }
                          printf("TypeOf: %s\n", typeOf_params[0]); 
                        }

                        if(strcmp(get_function_type($1), "specialEval") == 0)
                        {
                          int value = evalAST((struct node*)$3);
                           printf("Eval: %d\n", value);
                        }
                        index_typeOf = 0;
                        bzero(actually_params, 300);
                    }
                }
              | VARIABLE ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE SEMICOLON
                {
                    if(check_if_function_exists($1) == 0)
                      return 0;
                      else
                      {
                        if(strcmp(get_parameters($1),"none") != 0)
                          {
                            yyerror("This function has other parameters");
                            return 0;
                          }
                      }
                }
              ;

// |---------> PARAMETRI APEL FUNCTIE <---------|
list_parameters : list_p
                | list_parameters COMMA list_p
                ;     

list_p : operand_p
       | list_p PLUS list_p
         {    

              struct node* node = (struct node*)malloc(sizeof(struct node));
              strcpy(node->value.operator, $2);
              $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");

              char last[20]="", alast[20]="";
              char aux[300]="";
              strcpy(aux, actually_params);
              char* p;
              p = strtok(aux, " ");
              strcpy(last, p);
              while(p)
              {
                strcpy(alast, last);
                strcpy(last, p);
                p = strtok(NULL, " ");
              }
              if(strcmp(last, alast) != 0)
              {
                //printf("%s--%s--", last, alast);
                yyerror("Operands in '+' operation have different types");
                return 0;
              }
              else
              {
                int len = strlen(last);
                strcpy(actually_params+strlen(actually_params)-len-2, " ");
                //strcat(actually_params, " ");
              }
          }
       | list_p MINUS list_p
         {
              struct node* node = (struct node*)malloc(sizeof(struct node));
              strcpy(node->value.operator, $2);
              $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");

              char last[20]="", alast[20]="";
              char aux[300]="";
              strcpy(aux, actually_params);
              char* p;
              p = strtok(aux, " ");
              strcpy(last, p);
              while(p)
              {
                strcpy(alast, last);
                strcpy(last, p);
                p = strtok(NULL, " ");
              }
              if(strcmp(last, alast) != 0)
              {
                //printf("%s--%s--", last, alast);
                yyerror("Operands in '~' operation have different types");
                return 0;
              }
              else
              {
                int len = strlen(last);
                strcpy(actually_params+strlen(actually_params)-len-2, " ");
                //strcat(actually_params, " ");
              }
          }
       | list_p MUL list_p
          {
              struct node* node = (struct node*)malloc(sizeof(struct node));
              strcpy(node->value.operator, $2);
              $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");

              char last[20]="", alast[20]="";
              char aux[300]="";
              strcpy(aux, actually_params);
              char* p;
              p = strtok(aux, " ");
              strcpy(last, p);
              while(p)
              {
                strcpy(alast, last);
                strcpy(last, p);
                p = strtok(NULL, " ");
              }
              if(strcmp(last, alast) != 0)
              {
                //printf("%s--%s--", last, alast);
                yyerror("Operands in '*' operation have different types");
                return 0;
              }
              else
              {
                int len = strlen(last);
                strcpy(actually_params+strlen(actually_params)-len-2, " ");
                //strcat(actually_params, " ");
              }
          }
       | list_p DIV list_p
          {
              struct node* node = (struct node*)malloc(sizeof(struct node));
              strcpy(node->value.operator, $2);
              $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");

              char last[20]="", alast[20]="";
              char aux[300]="";
              strcpy(aux, actually_params);
              char* p;
              p = strtok(aux, " ");
              strcpy(last, p);
              while(p)
              {
                strcpy(alast, last);
                strcpy(last, p);
                p = strtok(NULL, " ");
              }
              if(strcmp(last, alast) != 0)
              {
                //printf("%s--%s--", last, alast);
                yyerror("Operands in '/' operation have different types");
                return 0;
              }
              else
              {
                int len = strlen(last);
                strcpy(actually_params+strlen(actually_params)-len-2, " ");
                //strcat(actually_params, " ");
              }
          }
       | ROUND_BRACKET_OPEN list_p ROUND_BRACKET_CLOSE {$$ = $2;}
       ;

operand_p :  STRING_VALUE
            {
              strcat(actually_params,"string ");
              strcpy(typeOf_params[index_typeOf], "string");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = 0;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
            }
          | function_call_inside 
            {
              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = 0;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
            }
          | CHAR
            {
              strcat(actually_params,"char ");
              strcpy(typeOf_params[index_typeOf], "char");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = 0;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
            }
          | FLOAT
            {
              strcat(actually_params,"float ");
              strcpy(typeOf_params[index_typeOf], "float");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = $1;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
            }
          | INT
            {
              strcat(actually_params,"int ");
              strcpy(typeOf_params[index_typeOf], "int");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = $1;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
            }
          | UNSIGNED
            {
              strcat(actually_params,"unsigned ");
              strcpy(typeOf_params[index_typeOf], "unsigned");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = $1;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
            }
          | BOOL_VAR
            {
              strcat(actually_params,"bool ");
              strcpy(typeOf_params[index_typeOf], "bool");
              index_typeOf++;

              struct node* node = (struct node*)malloc(sizeof(struct node));
              node->value.number = 0;
              $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
            }
          | VARIABLE
            {
              if(check_if_variable_exists($1) == 0)
                return 0;
              switch (get_type($1)) 
                {
                  case 0: {
                      strcat(actually_params,"int ");
                      strcpy(typeOf_params[index_typeOf], "int");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value($1));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                      break;
                  }
                  case 1: {
                      strcat(actually_params,"float ");
                      strcpy(typeOf_params[index_typeOf], "float");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value($1));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                      break;
                  } 
                  case 2: {
                      strcat(actually_params,"unsigned ");
                      strcpy(typeOf_params[index_typeOf], "unsigned");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value($1));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                      break;
                  } 
                  case 3: {
                      strcat(actually_params,"char ");
                      strcpy(typeOf_params[index_typeOf], "char");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 4: {
                      strcat(actually_params,"string ");
                      strcpy(typeOf_params[index_typeOf], "string");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 5: {
                      strcat(actually_params,"bool ");
                      strcpy(typeOf_params[index_typeOf], "bool");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 6: {
                      strcat(actually_params,"int ");
                      strcpy(typeOf_params[index_typeOf], "int");
                      index_typeOf++;
                      break;
                  } 
                  case 7: {
                      strcat(actually_params,"float ");
                      strcpy(typeOf_params[index_typeOf], "float");
                      index_typeOf++;
                      break;
                  } 
                  case 8: {
                      strcat(actually_params,"unsigned ");
                      strcpy(typeOf_params[index_typeOf], "unsigned");
                      index_typeOf++;
                      break;
                  } 
                  case 9: {
                      strcat(actually_params,"char ");
                      strcpy(typeOf_params[index_typeOf], "char");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  case 10: {
                      strcat(actually_params,"string ");
                      strcpy(typeOf_params[index_typeOf], "string");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  case 11: {
                      strcat(actually_params,"class ");
                      strcpy(typeOf_params[index_typeOf], "class");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  default:
                  {
                    strcat(actually_params,"default ");
                    strcpy(typeOf_params[index_typeOf], "default");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                  }    
                }
           }
           | ARRAY
              {
              char aux[100]="",number[10]="";
              strcpy(aux, $1);
              int i = 0;
              while(aux[i]!='[')
                i++;
              strcpy(number, aux+i+1);
              number[strlen(number)-1] = '\0';
              aux[i]='\0';
              int nr = atoi(number);
              int ind = index_arr_return(aux);
              if(nr >= 0 && nr < max_arr_index(ind))
              {
                if(check_if_variable_exists(aux) == 0)
                {
                  return 0;
                }
                switch (get_type(aux)) 
                {
                  case 0: {
                      strcat(actually_params,"int ");
                      strcat(typeOf_params[index_typeOf], "int");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                      break;
                  }
                  case 1: {
                      strcat(actually_params,"float ");
                      strcat(typeOf_params[index_typeOf], "float");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                      break;
                  } 
                  case 2: {
                      strcat(actually_params,"unsigned ");
                      strcat(typeOf_params[index_typeOf], "unsigned");
                      index_typeOf++;
                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                      break;
                  } 
                  case 3: {
                      strcat(actually_params,"char ");
                      strcat(typeOf_params[index_typeOf], "char");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 4: {
                      strcat(actually_params,"string ");
                      strcat(typeOf_params[index_typeOf], "string");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 5: {
                      strcat(actually_params,"bool ");
                      strcat(typeOf_params[index_typeOf], "bool");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  } 
                  case 6: {
                      strcat(actually_params,"int ");
                      strcat(typeOf_params[index_typeOf], "int");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
                      break;
                  } 
                  case 7: {
                      strcat(actually_params,"float ");
                      strcat(typeOf_params[index_typeOf], "float");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "float");
                      break;
                  } 
                  case 8: {
                      strcat(actually_params,"unsigned ");
                      strcat(typeOf_params[index_typeOf], "unsigned");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      char valoare[20] = "";
                      strcpy(valoare, get_value(aux));

                      node->value.number = atoi(valoare);
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "unsigned");
                      break;
                  } 
                  case 9: {
                      strcat(actually_params,"char ");
                      strcat(typeOf_params[index_typeOf], "char");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  case 10: {
                      strcat(actually_params,"string ");
                      strcat(typeOf_params[index_typeOf], "string");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  case 11: {
                      strcat(actually_params,"class ");
                      strcat(typeOf_params[index_typeOf], "class");
                      index_typeOf++;

                      struct node* node = (struct node*)malloc(sizeof(struct node));
                      node->value.number = 0;
                      $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                      break;
                  }
                  default:
                  {
                    strcat(actually_params,"default ");
                    strcat(typeOf_params[index_typeOf], "default");
                    index_typeOf++;

                    struct node* node = (struct node*)malloc(sizeof(struct node));
                    node->value.number = 0;
                    $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "default");
                    break;
                  }    
                }
              }
              else
              {
                yyerror("Position out of range");
                return 0;
              }
              }
          ;

operand_pp : STRING_VALUE
          | CHAR
          | FLOAT
          | INT
          | UNSIGNED
          | BOOL_VAR
          | VARIABLE
          ;

// |--------->  APEL FUNCTIE IN FUNCTIE <-------|
function_call_inside : VARIABLE ROUND_BRACKET_OPEN list_parameterss ROUND_BRACKET_CLOSE
                       {
                        bzero(actually_params,300);
                        if(check_if_function_exists($1) == 0)
                          return 0;
                        strcat(actually_params, get_function_type($1));
                        strcat(actually_params, " ");
                        strcpy(typeOf_params[index_typeOf], get_function_type($1));
                        index_typeOf++;   
                        struct node* node = (struct node*)malloc(sizeof(struct node));
                        
                        node->value.number = 0;

                        $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, get_function_type($1));
                       }
                     ;

list_parameterss : list_ppp
                | list_parameterss COMMA list_ppp
                ;     

list_ppp : operand_ppp
       | list_ppp PLUS list_ppp
       | list_ppp MINUS list_ppp
       | list_ppp MUL list_ppp
       | list_ppp DIV list_ppp
       | ROUND_BRACKET_OPEN list_ppp ROUND_BRACKET_CLOSE
       ;

operand_ppp :  STRING_VALUE
            {
              strcat(actually_params,"string ");
            }
          | function_call_inside
          | CHAR
            {
              strcat(actually_params,"char ");
            }
          | FLOAT
            {
              strcat(actually_params,"float ");
            }
          | INT
            {
              strcat(actually_params,"int ");
            }
          | UNSIGNED
            {
              strcat(actually_params,"unsigned ");
            }
          | BOOL_VAR
            {
              strcat(actually_params,"bool ");
            }
          | VARIABLE
            {
              if(check_if_variable_exists($1) == 0)
                return 0;
              switch (get_type($1)) 
                {
                  case 0: {
                      strcat(actually_params,"int ");
                      break;
                  }
                  case 1: {
                      strcat(actually_params,"float ");
                      break;
                  } 
                  case 2: {
                      strcat(actually_params,"unsigned ");
                      break;
                  } 
                  case 3: {
                      strcat(actually_params,"char ");
                      break;
                  } 
                  case 4: {
                      strcat(actually_params,"string ");
                      break;
                  } 
                  case 5: {
                      strcat(actually_params,"bool ");
                      break;
                  } 
                  case 6: {
                      strcat(actually_params,"int ");
                      break;
                  } 
                  case 7: {
                      strcat(actually_params,"float ");
                      break;
                  } 
                  case 8: {
                      strcat(actually_params,"unsigned ");
                      break;
                  } 
                  case 9: {
                      strcat(actually_params,"char ");
                      break;
                  }
                  case 10: {
                      strcat(actually_params,"string ");
                      break;
                  }
                  case 11: {
                      strcat(actually_params,"class ");
                      break;
                  }
                  default:
                  {
                    strcat(actually_params,"default ");
                    break;
                  }    
                }
           }
           | ARRAY
              {
              char aux[100]="",number[10]="";
              strcpy(aux, $1);
              int i = 0;
              while(aux[i]!='[')
                i++;
              strcpy(number, aux+i+1);
              number[strlen(number)-1] = '\0';
              aux[i]='\0';
              int nr = atoi(number);
              int ind = index_arr_return(aux);
              if(nr >= 0 && nr < max_arr_index(ind))
              {
                if(check_if_variable_exists(aux) == 0)
                {
                  return 0;
                }
                switch (get_type(aux)) 
                {
                  case 0: {
                      strcat(actually_params,"int ");
                      break;
                  }
                  case 1: {
                      strcat(actually_params,"float ");
                      break;
                  } 
                  case 2: {
                      strcat(actually_params,"unsigned ");
                      break;
                  } 
                  case 3: {
                      strcat(actually_params,"char ");
                      break;
                  } 
                  case 4: {
                      strcat(actually_params,"string ");
                      break;
                  } 
                  case 5: {
                      strcat(actually_params,"bool ");
                      break;
                  } 
                  case 6: {
                      strcat(actually_params,"int ");
                      break;
                  } 
                  case 7: {
                      strcat(actually_params,"float ");
                      break;
                  } 
                  case 8: {
                      strcat(actually_params,"unsigned ");
                      break;
                  } 
                  case 9: {
                      strcat(actually_params,"char ");
                      break;
                  }
                  case 10: {
                      strcat(actually_params,"string ");
                      break;
                  }
                  case 11: {
                      strcat(actually_params,"class ");
                      break;
                  }
                  default:
                  {
                    strcat(actually_params,"default ");
                    break;
                  }    
                }
              }
              else
              {
                yyerror("Position out of range");
                return 0;
              }
              }
          ;

// |-------------> LISTA FUNCTII <--------------|
list_functions : func
               | list_functions func
               ;

// |-----------------> FUNCTII <----------------|
func : DATA_TYPE VARIABLE ROUND_BRACKET_OPEN variable_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list RETURN operand SEMICOLON CURLY_BRACKET_CLOSE
       {
          if(is_duplicate_function($2) == 0 && is_duplicate($2) == 0)
          {
            strcpy(functions1[index_fun1].type1, $1);
            strcpy(functions1[index_fun1].name1, $2);
            add_new_fun(functions1[index_fun1].type1, functions1[index_fun1].name1, params[index_params]);
            index_params++;
            index_fun1++;
            write_fun();
          }
          else
          {
            return 0;
          }
       }
     | DATA_TYPE VARIABLE ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list RETURN operand SEMICOLON CURLY_BRACKET_CLOSE
       {
        if(is_duplicate_function($2) == 0 && is_duplicate($2) == 0)
        {
          strcpy(functions1[index_fun1].type1, $1);
          strcpy(functions1[index_fun1].name1, $2);
          add_new_fun(functions1[index_fun1].type1, functions1[index_fun1].name1, "none");
          index_fun1++;
          write_fun();
        }
        else
        {
          return 0;
        }
       }
     | VOID VARIABLE ROUND_BRACKET_OPEN variable_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
       {
        if(is_duplicate_function($2) == 0 && is_duplicate($2) == 0)
        {
          strcpy(functions1[index_fun1].type1, "void");
          strcpy(functions1[index_fun1].name1, $2);
          add_new_fun(functions1[index_fun1].type1, functions1[index_fun1].name1, params[index_params]);
          index_params++;
          index_fun1++;
          write_fun();
        }
        else
        {
          return 0;
        }
       }
     | VOID VARIABLE ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
        {
          if(is_duplicate_function($2) == 0 && is_duplicate($2) == 0)
          {
            strcpy(functions1[index_fun1].type1, "void");
            strcpy(functions1[index_fun1].name1, $2);
            add_new_fun(functions1[index_fun1].type1, functions1[index_fun1].name1, "none");
            index_fun1++;
            write_fun();
          }
          else
          {
            return 0;
          }
        }
     | DATA_TYPE VARIABLE ROUND_BRACKET_OPEN variable_list ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
        {
          yyerror("This function must return a value");
          return 0;
        }  
     | DATA_TYPE VARIABLE ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE CURLY_BRACKET_OPEN list CURLY_BRACKET_CLOSE
        {
          yyerror("This function must return a value");
          return 0;
        }
     ;

// |---------> PARAMETRII DECL FUNCTIE <--------|
variable_list : var
              | variable_list COMMA var
              ;

// |-----------> PARAMETRU FUNCTIE <------------|
var : DATA_TYPE VARIABLE 
      {
          if(is_duplicate($2) == 0)
          {
            strcat(params[index_params], $1);
            strcat(params[index_params], " ");
            add_new_var($1, $2, "NULL", "function_parameter");
            write_var();
          }
          else
          {
            return 0;
          }
      }
    ;

// |--------------> LISTA DEFINE <--------------|
defines_list : define 
             | defines_list define
             ;

// |-----------------> DEFINE <-----------------|
define : DEF VARIABLE operand_pp
       ;

// |---------------> LISTA CLASE <--------------|
classes_list : class
             | classes_list class
             ;

// |-----------------> CLASA <------------------|
class : CLASS_TYPE VARIABLE CURLY_BRACKET_OPEN declarations list_functions CURLY_BRACKET_CLOSE
        {
          if(is_duplicate($2) == 0 && is_duplicate_function($2) == 0)
          {
            add_new_var($1, $2, "NULL", scope);
            write_var();
          }
          else
            {
              return 0;
            }
        }        
      ;

%%

void yyerror (char *s) 
{
   fprintf (stderr, "Error: %s, at line: %d.\n", s,yylineno);
}

int main(int argc, char** argv)
{
    yyin=fopen(argv[1],"r");
    yyparse();
}
