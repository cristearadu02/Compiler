#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno; 
extern void yyerror(char *s);

void reverse2(char* str, int len)
{
    int i = 0, j = len - 1, temp;
    while (i < j) {
        temp = str[i];
        str[i] = str[j];
        str[j] = temp;
        i++;
        j--;
    }
}

int intToStr(int x, char str[], int d)
{
    int i = 0;
    while (x) {
        str[i++] = (x % 10) + '0';
        x = x / 10;
    }
 

    while (i < d)
        str[i++] = '0';
 
    reverse2(str, i);
    str[i] = '\0';
    return i;
}
 
void ftoa(float n, char* res, int afterpoint)
{
    int ipart = (int)n;
 
    float fpart = n - (float)ipart;
 
    int i = intToStr(ipart, res, 0);
 
    if (afterpoint != 0) {
        res[i] = '.'; 

        int x = afterpoint;
        int y = 1;
        while(x)
        {
            y = y * 10;
            x--;
        }

        fpart = fpart * y;
 
        intToStr((int)fpart, res + i + 1, afterpoint);
    }
}
 
// CONVERTIRE DE LA NUMAR LA CHAR* 
void swap(char *x, char *y) {
    char t = *x; *x = *y; *y = t;
}

char* reverse(char *buffer, int i, int j)
{
    while (i < j) {
        swap(&buffer[i++], &buffer[j--]);
    }
 
    return buffer;
}
 
char* itoa(int value, char* buffer, int base)
{
    // invalid input
    if (base < 2 || base > 32) {
        return buffer;
    }
    int n = abs(value);
 
    int i = 0;
    while (n)
    {
        int r = n % base;
 
        if (r >= 10) {
            buffer[i++] = 65 + (r - 10);
        }
        else {
            buffer[i++] = 48 + r;
        }
 
        n = n / base;
    }
    if (i == 0) {
        buffer[i++] = '0';
    }
    if (value < 0 && base == 10) {
        buffer[i++] = '-';
    }
 
    buffer[i] = '\0'; 
 
   
    return reverse(buffer, 0, i - 1);
}
 //-----------------------------------------------

struct var
{
  char type[100];
  char name[100];
  char value[100];
  char scope[100];

}variables[1000];
int index_var = 0;

struct fun
{
    char type[100];
    char name[100];
    char parameters[300];

}functions[1000];
int index_fun = 0;

struct arr
{
    char type[100];
    char name[100];
    char scope[100];
    int  max_range;
    char value[100][100];

}array[1000];
int index_arr = 0;

void add_special_functions()
{
    strcpy(functions[index_fun].type, "specialTypeOf");
    strcpy(functions[index_fun].name, "TypeOf");
    strcpy(functions[index_fun].parameters, "specialParameters");
    index_fun++;
    strcpy(functions[index_fun].type, "specialEval");
    strcpy(functions[index_fun].name, "Eval");
    strcpy(functions[index_fun].parameters, "specialParameters");
    index_fun++;
}

void add_new_var(char* tip,char* nume, char* valoare, char* scop)
{
    strcpy(variables[index_var].type,tip);
    strcpy(variables[index_var].name,nume);
    strcpy(variables[index_var].value,valoare);
    strcpy(variables[index_var].scope,scop);
    index_var++;
}

void add_new_fun(char* tip,char* nume, char* par)
{
    strcpy(functions[index_fun].type,tip);
    strcpy(functions[index_fun].name,nume);
    strcpy(functions[index_fun].parameters, par);
    index_fun++;
}

void add_new_arr(char* tip, char* nume, char* scop, int maxx_range)
{
    strcpy(array[index_arr].type,tip);
    strcpy(array[index_arr].name,nume);
    array[index_arr].max_range=maxx_range;
    strcpy(array[index_arr].scope,scop);
    index_arr++;
}

int index_arr_return(char* array_name)
{
    int i;
    for (i=0; i<index_arr; i++)
    {
        if(strcmp(array_name, array[i].name) == 0)
        {
            return i;
        }
    }
    return -1;
}

void add_arr_value(int poz, int i,char* val)
{
    strcpy(array[poz].value[i], val);

}

int max_arr_index(int index)
{
    return array[index].max_range;
}

void write_fun()
{
   remove("Symbol_table_functions.txt");
   int fd_functions = open("Symbol_table_functions.txt", O_WRONLY | O_CREAT, 0666);
   char content[10000]="";
   for(int i=0; i<index_fun; i++)
   {
      char aux[10]="";
      itoa(i+1,aux,10);
      strcat(content, "< Function nr:");
      strcat(content,aux);
      strcat(content," > < type: ");
      strcat(content, functions[i].type);
      strcat(content," > < name: ");
      strcat(content, functions[i].name);
      strcat(content, " > < params: ");
      strcat(content, functions[i].parameters);
      strcat(content, " >\n");
   }
   write(fd_functions,content,strlen(content));
   close(fd_functions);
}

void write_var()
{
   remove("Symbol_table.txt");
   int fd = open("Symbol_table.txt",O_WRONLY | O_CREAT, 0666);
   char content[15000]="";
   for(int i = 0; i < index_var; i++)
    {   
        char aux[10]="";
        itoa(i+1,aux,10);
        strcat(content, "< Variable nr:");
        strcat(content,aux);
        strcat(content," > < type: ");
        strcat(content, variables[i].type);
        strcat(content," > < name: ");
        strcat(content, variables[i].name);
        strcat(content," > < value: ");
        strcat(content, variables[i].value);
        strcat(content," > < scope: ");
        strcat(content, variables[i].scope);

        strcat(content," >\n");
    } 

    for(int i = 0; i < index_arr; i++)
    { 
        char buff[10]="";
        char aux[10]="";
        itoa(i+1,aux,10);
        strcat(content, "< Array nr:");
        strcat(content,aux);
        strcat(content," > < type: ");
        strcat(content, array[i].type);
        strcat(content," > < name: ");
        strcat(content, array[i].name);
        itoa(array[i].max_range, buff, 10);
        strcat(content," > < max_range: ");
        strcat(content, buff);
        strcat(content, " > < values: ");
        for(int j = 0; j < 100; j++)
        { //printf("%d ",j);
            if(strlen(array[i].value[j]))
            {
                strcat(content, "[");
                char auxx[10]="";
                itoa(j,auxx,10);
                strcat(content, auxx);
                strcat(content, "]->");
                strcat(content, array[i].value[j]);
                strcat(content, " ");
            }
        }
        strcat(content,">\n");
    }

    write(fd,content,strlen(content));
    close(fd);
}

int is_duplicate(char* var_name)    //check if a variable has been declared more than once
{
    int i;
    for (i=0; i<index_var; i++)
    {
        if(strcmp(var_name, variables[i].name) == 0)
        {
            char err[100]="Variable '";
            strcat(err,var_name);
            strcat(err, "' declared more than once");
            yyerror(err);
            return 1;
        }
    }
    return 0;
}

int is_duplicate_function(char* function_name)    //check if a variable has been declared more than once
{
    int i;
    for (i=0; i<index_fun; i++)
    {
        if(strcmp(function_name, functions[i].name) == 0)
        {
            char err[100]="Function '";
            strcat(err,function_name);
            strcat(err, "' declared more than once");
            yyerror(err);
            return 1;
        }
    }
    return 0;
}

int check_if_function_exists(char* function_name)    //check if a variable has been declared more than once
{
    int i;
    for (i=0; i<index_fun; i++)
    {
        if(strcmp(function_name, functions[i].name) == 0)
        {
            return 1;
        }
    }
    char err[100]="Function '";
    strcat(err,function_name);
    strcat(err, "' has not been defined");
    yyerror(err);
    return 0;
}

int check_if_variable_exists(char* var_name)
{
    int i;
    for(i=0; i<index_var; i++)
    {
        if(strcmp(var_name, variables[i].name) == 0)
        {
            return 1;
        }
    }
    for(i=0; i<index_arr; i++)
    {
        if(strcmp(var_name, array[i].name) == 0)
        {
            return 1;
        }
    }
    char err[100]="Variable ";
    strcat(err,var_name);
    strcat(err, " has not been defined");
    yyerror(err);
    return 0;
}

char* get_array_value(int poz, int index)
{
    return array[poz].value[index];
}

char* get_parameters(char* fun_name)
{
    int i;
    for(i=0; i<index_fun; i++)
    {
        if(strcmp(fun_name, functions[i].name) == 0)
        {
            return functions[i].parameters;
        }
    }
}

void update_value(char* var_name, char* new_value)
{
    int i;
    for(i=0; i<index_var; i++)
    {
        if(strcmp(var_name, variables[i].name) == 0)
        {
            strcpy(variables[i].value, new_value);
            break;
        }
    }
}

int get_type(char* var_name)
{
    int i;
    for(i=0; i<index_var; i++)
    {
        if(strcmp(var_name, variables[i].name) == 0)
        {
            if(strcmp(variables[i].type, "int") == 0)
                return 0;
            if(strcmp(variables[i].type, "float") == 0)
                return 1;
            if(strcmp(variables[i].type, "unsigned") == 0)
                return 2;
            if(strcmp(variables[i].type, "char") == 0)
                return 3;
            if(strcmp(variables[i].type, "string") == 0)
                return 4;
            if(strcmp(variables[i].type, "bool") == 0)
                return 5;
            if(strcmp(variables[i].type, "const int") == 0)
                return 6;
            if(strcmp(variables[i].type, "const float") == 0)
                return 7;
            if(strcmp(variables[i].type, "const unsigned") == 0)
                return 8;
            if(strcmp(variables[i].type, "const char") == 0)
                return 9;
            if(strcmp(variables[i].type, "const string") == 0)
                return 10;
            if(strstr(variables[i].type, "class") != NULL)
                return 11;
        }
    }

    for(i=0; i<index_arr; i++)
    {
        if(strcmp(var_name, array[i].name) == 0)
        {
            if(strcmp(array[i].type, "int") == 0)
                return 0;
            if(strcmp(array[i].type, "float") == 0)
                return 1;
            if(strcmp(array[i].type, "unsigned") == 0)
                return 2;
            if(strcmp(array[i].type, "char") == 0)
                return 3;
            if(strcmp(array[i].type, "string") == 0)
                return 4;
            if(strcmp(array[i].type, "bool") == 0)
                return 5;
            if(strcmp(array[i].type, "const int") == 0)
                return 6;
            if(strcmp(array[i].type, "const float") == 0)
                return 7;
            if(strcmp(array[i].type, "const unsigned") == 0)
                return 8;
            if(strcmp(array[i].type, "const char") == 0)
                return 9;
            if(strcmp(array[i].type, "const string") == 0)
                return 10;
        }
    }
}

char* get_function_type(char* fun_name)
{
    for(int i=0; i<index_fun; i++)
    {
        if(strcmp(fun_name, functions[i].name) == 0)
        {
            return functions[i].type;
        }
    }
}

char* get_value(char* var_name)
{
    int i;
    for(i=0; i<index_var; i++)
    {
        if(strcmp(var_name, variables[i].name) == 0)
        {
            return variables[i].value;
        }
    }
}


/*int checkIfFunctionExists(char* funct_name)
{
    int i;
    for(i=0; i<funct_index; i++)
    {
        if(strcmp(funct_name, functions[i].name) == 0)
        {
            return 1;
        }
    }
    printf("\nError on line %d : Function '%s' has not been defined.\n", yylineno, var_name);
    return 0;
}*/


union root_value{
     int number;
     char identifier[10];
     char operator[10];
};


struct node{
     union root_value value; 
     struct node* left;
     struct node* right;
     char* type;

};

struct node* buildAST(struct node* root, struct node* left_tree, struct node* right_tree, char* type)
{
     root->type = type;
     root->left = left_tree;
     root->right = right_tree;   
     return (root);

};

int evalAST(struct node* ast)
{ 

     if(strcmp(ast->type, "op") == 0)
     {
          int left_tree, right_tree;

          if(ast->left != NULL) 
            left_tree = evalAST(ast->left);

          if(ast->right != NULL) 
            right_tree = evalAST(ast->right);

          if(strcmp(ast->value.operator, "+") == 0)
          {
               return left_tree + right_tree; 
          }
          else if(strcmp(ast->value.operator, "~") == 0)
          {
               return left_tree - right_tree; 
          }
          else if(strcmp(ast->value.operator, "/") == 0)
          {
               return left_tree / right_tree; 
          }
          else if(strcmp(ast->value.operator, "*") == 0)
          {
               return left_tree * right_tree; 
          }
          
     }
     else if(strcmp(ast->type, "int") == 0)
     {
          return(ast->value.number);
     }
     else if(strcmp(ast->type, "id") == 0)
     { 
          if(check_if_variable_exists(ast->value.identifier) == 1)
          { 
               if(get_type(ast->value.identifier)==0)
                {   

                    return atoi(get_value(ast->value.identifier));
                }
               else 
                return 0;
          }
     }
     else if(strcmp(ast->type, "default") == 0){
          return 0;
     }
     
}
