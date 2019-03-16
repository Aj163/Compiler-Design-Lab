#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MOD 1007
#define PRIME 23

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
        hashValue = (hashValue * PRIME + str[i]) % MOD;

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