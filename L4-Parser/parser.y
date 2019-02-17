%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>

    #define MOD 1007
    #define P 23

    typedef struct Node{
        char name[100], type[100];
        int lineNo;
        struct Node *next;
    } node;

    node *symbolTable[MOD] = {NULL};

    int hash(char str)[] {

        int len = strlen(str);
        int hashValue = 0;
        for(int i=0; i<len; i++)
            hashValue = (hashValue * P + str[i]) % MOD;

        return hashValue;
    }

    node *lookup(char str[]) {

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

    void insert(char str[]) {

        node *temp = malloc(sizeof(node));
        strcpy(temp->name, str);

        int hashValue = hash(str);

        temp->next = symbolTable[hashValue];
        symbolTable[hashValue] = temp;
    }
%}

%token INT MAIN FOR RETURN 
%token STRING_CONSTANT INTEGER_CONSTANT IDENTIFIER
%token INCREMENT DeCREMENT

%left '+' '-'
%left '*' '/' '%'
%left '='

%%

Global
    : FunDec Global
    | FunDef Global
    | VarDec Global
    |
    ;

FunDec
    : DataType IDENTIFIER '(' ParamList ')' ';'
    ;

VarDec
    : DataType VarList ';'
    ;

VarList
    : IDENTIFIER ',' VarList
    | IDENTIFIER '=' Expression ',' VarList
    | IDENTIFIER ';'
    | IDENTIFIER '=' Expression ';'
    ;

Expression
    : Term
    | Expression '+' Term
    | Expression '-' Term
    | Expression '*' Term
    | Expression '/' Term
    | Expression '%' Term
    | Expression '=' Term
    ;

Term
    : IDENTIFIER
    | INTEGER_CONSTANT
    | STRING_CONSTANT
    | FuncCall
    ;

ParamList
    : DataType IDENTIFIER ',' ParamList
    |
    ;

DataType
    : INT
    ;

FunDef
    : DataType IDENTIFIER '(' ParamList ')' '{' StatList '}' ';'
    ;

StatList
    : SingleStat ';' StatList
    | '{' StatList '}' StatList
    |
    ;

SingleStat
    : Expression
    | ForStat
    | VarDec
    | ReturnStat
    | FuncCall
    ;

ForStat
    : FOR '(' VarDec ';' Expression ';' Expression ')' SingleStat ';'
    | FOR '(' Expression ';' Expression ';' Expression ')' SingleStat ';'
    | FOR '(' VarDec ';' Expression ';' Expression ')' '{' StatList '}'
    | FOR '(' Expression ';' Expression ';' Expression ')' '{' StatList '}'
    ;

ReturnStat
    : RETURN Expression ';'
    | RETURN ';'

FuncCall
    : IDENTIFIER '(' ArgList ')'
    ;

ArgList
    : Expression ',' ArgList
    |
    ;
%%