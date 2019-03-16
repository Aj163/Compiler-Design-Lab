#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define YYSTYPE char*
#include "lex.yy.c"

extern int yylineno;
void yyerror(char *s) {

    fprintf(stderr, "%s\n", s);
    exit(1);
}

#define MOD 1007
#define PRIME 23

typedef struct Node{
    char name[100], type[100];
    int lineNo;
    struct Node *next;
    int scope;
} node;

node *symbolTable[MOD] = {NULL};
node *stack[MOD];
char type[100];
int curr_scope = 0;
int tos = -1;

void redeclared(const char *name) {

    int ptr = tos;
    while(stack[ptr]->scope == curr_scope) {
        if(!strcmp(stack[ptr]->name, name)) {
            printf("Line %d: %s has been redeclared.\n", yylineno, name);
            exit(1);
        }
        ptr--;
    }
}

void not_declared(const char *name) {

    int ptr = tos;
    while(ptr >= 0) {
        if(!strcmp(stack[ptr]->name, name))
            return;
        ptr--;
    }

    printf("Line %d: %s has not been declared.\n", yylineno, name);
    exit(1);
}

int hash(const char *str) {

    int len = strlen(str);
    int hashValue = 0;
    for(int i=0; i<len; i++)
        hashValue = (hashValue * PRIME + str[i]) % MOD;

    return hashValue;
}

void insert(int lineNo, const char *name, const char *type, int scope) {

    node *temp = malloc(sizeof(node));
    strcpy(temp->name, name);
    strcpy(temp->type, type);
    temp->lineNo = lineNo;
    temp->scope = scope;

    int hashValue = hash(name);

    temp->next = symbolTable[hashValue];
    symbolTable[hashValue] = temp;
    stack[++tos] = temp;
}

void printSymbolTable() {

    printf("------------------------------------------------------------\n");
    printf("|%-10s|%-15s|%-20s|%-10s|\n", "Line No", "Data Type", "Name", "Scope");
    printf("------------------------------------------------------------\n");
    node *temp;
    for(int i=0; i<MOD; i++) {
        temp = symbolTable[i];
        while(temp != NULL) {
            printf("|%-10d|%-15s|%-20s|%-10d|\n", temp->lineNo, temp->type, temp->name, temp->scope);
            temp = temp->next;
        }
    }
    printf("------------------------------------------------------------\n");
}