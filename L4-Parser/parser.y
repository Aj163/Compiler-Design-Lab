%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>

    #define MOD 1007
    #define P 23

    #define YYSTYPE char*
    #include "lex.yy.c"

    int yylex();
    void yyerror(char *);
    extern int yylineno;

    char type[100];

    typedef struct Node{
        char name[100], type[100];
        int lineNo;
        struct Node *next;
    } node;

    node *symbolTable[MOD] = {NULL};

    int hash(const char *str) {

        int len = strlen(str);
        int hashValue = 0;
        for(int i=0; i<len; i++)
            hashValue = (hashValue * P + str[i]) % MOD;

        return hashValue;
    }

    node *lookup(const char *str) {

        int len = strlen(str);
        int hashValue = hash(str);

        node *temp = symbolTable[hashValue];
        while(temp != NULL) {
            if(!strcmp(str, temp->name))
                return temp;
            temp = temp->next;
        }

        return NULL;
    }

    void insert(int lineNo, const char *name, const char *type) {

        if(lookup(name) != NULL)
            return;

        node *temp = malloc(sizeof(node));
        strcpy(temp->name, name);
        strcpy(temp->type, type);
        temp->lineNo = lineNo;

        int hashValue = hash(name);

        temp->next = symbolTable[hashValue];
        symbolTable[hashValue] = temp;
    }
%}

%token INT MAIN FOR RETURN 
%token STRING_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token INCREMENT DECREMENT PLUSEQ

%left '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left '=' PLUSEQ

%%
Global
    : FunDec Global
    | FunDef Global
    | VarDec ';' Global
    |
    ;

FunDec
    : DataType IDENTIFIER '(' ParamList ')' ';'     { insert(yylineno, $2, type); }
    | DataType IDENTIFIER '(' ')' ';'               { insert(yylineno, $2, type); }
    ;

VarDec
    : DataType VarList
    ;

VarList
    : IDENTIFIER                                                    { insert(yylineno, $1, type); }
    | IDENTIFIER ',' VarList                                        { insert(yylineno, $1, type); }
    | IDENTIFIER '=' Expression ',' VarList                         { insert(yylineno, $1, type); }
    | IDENTIFIER '=' Expression                                     { insert(yylineno, $1, type); }
    ;

Expression
    : Term
    | Expression '+' Expression
    | Expression '<' Expression
    | Expression '>' Expression
    | Expression '-' Expression
    | Expression '*' Expression
    | Expression '/' Expression
    | Expression '%' Expression
    | Expression '=' Expression
    | Expression PLUSEQ Expression
    | '(' Expression ')'
    ;

Term
    : IDENTIFIER
    | INTEGER_CONSTANT
    | FLOAT_CONSTANT
    | STRING_CONSTANT
    | FuncCall
    ;

ParamList
    : DataType IDENTIFIER ',' ParamList
    | DataType IDENTIFIER
    ;

DataType
    : INT                                                           { strcpy(type, $1); }
    ;

FunDef
    : DataType IDENTIFIER '(' ParamList ')' '{' StatList '}'        { insert(yylineno, $2, type); }
    | DataType MAIN '(' ParamList ')' '{' StatList '}'              { insert(yylineno, $2, type); }
    | DataType IDENTIFIER '(' ')' '{' StatList '}'                  { insert(yylineno, $2, type); }
    | DataType MAIN '(' ')' '{' StatList '}'                        { insert(yylineno, $2, type); }
    ;

StatList
    : SingleStat ';' StatList
    | '{' StatList '}' StatList
    |
    ;

SingleStat
    : Expression
    | VarDec
    | ForStat
    | ReturnStat
    |
    ;

ForStat
    : FOR '(' VarDec ';' Expression ';' Expression ')' '{' StatList '}'
    | FOR '(' Expression ';' Expression ';' Expression ')' '{' StatList '}'
    | FOR '(' VarDec ';' Expression ';' Expression ')' SingleStat
    | FOR '(' Expression ';' Expression ';' Expression ')' SingleStat
    ;

ReturnStat
    : RETURN Expression
    | RETURN

FuncCall
    : IDENTIFIER '(' ArgList ')'
    | IDENTIFIER '(' ')'
    ;

ArgList
    : Expression ',' ArgList
    | Expression
    ;
%%

void yyerror(char *s) {

    fprintf(stderr, "%s\n", s);
}

void printSymbolTable() {

    printf("--------------------------------------------------------------------------\n");
    printf("|%-10s|%-20s|%-40s|\n", "Line No", "Data Type", "Name");
    printf("--------------------------------------------------------------------------\n");
    node *temp;
    for(int i=0; i<MOD; i++) {
        temp = symbolTable[i];
        while(temp != NULL) {
            printf("|%-10d|%-20s|%-40s|\n", temp->lineNo, temp->type, temp->name);
            temp = temp->next;
        }
    }
    printf("--------------------------------------------------------------------------\n");
}

int main() {

    yyparse();
    printSymbolTable();
}