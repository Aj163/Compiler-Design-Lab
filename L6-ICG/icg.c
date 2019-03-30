#include "symbol_table.c"

typedef struct {

    char name[100];
    int reg_num;
} reg_node;

typedef struct buffer_code{

    char code[100];
    struct buffer_code *next;
} buffer_node;

typedef struct TAC {

    int top;
    buffer_node *head[100];
    buffer_node *last[100];
} TAC;

TAC tac;
buffer_node *curr_buff;
char temp_code[100];

reg_node *icg_stack[MOD];
int icg_tos = -1;
int t_ctr = -1;
int label_num = 1;

buffer_node *get_buff_node() {

    buffer_node *node = malloc(sizeof(buffer_node));
    if(tac.last[tac.top] == NULL) {
        tac.last[tac.top] = node;
        tac.head[tac.top] = node;
    }
    else
        tac.last[tac.top]->next = node;
    tac.last[tac.top] = node;
    node->next = NULL;
    strcpy(node->code, "");

    return node;
}

char *reg_name(reg_node *temp) {

    char *str = (char *)malloc(100 * sizeof(char));
    strcpy(str, temp->name);
    if(temp->reg_num != -1) {
        sprintf(temp_code, "%d", temp->reg_num);
        strcat(str, temp_code);
    }

    return str;
}

reg_node *newNode(const char *name, int reg_num) {

    reg_node *temp =  malloc(sizeof(reg_node));
    strcpy(temp->name, name);
    temp->reg_num = reg_num;

    return temp;
}

reg_node *pop() {

    if(icg_tos == -1)
        return NULL;
    if(icg_stack[icg_tos]->reg_num != -1)
        t_ctr--;
    return icg_stack[icg_tos--];
}

void print_arg_list(int cnt) {

    if(cnt == 0)
        return;

    reg_node *temp = pop();
    print_arg_list(cnt -1);

    curr_buff = get_buff_node();
    sprintf(curr_buff->code, "param %s", reg_name(temp));
}

void exprTAC(const char *operator) {

    reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
    icg_stack[++icg_tos] = temp; 
    
    curr_buff = get_buff_node();
    sprintf(curr_buff->code, "%s = %s %s %s", reg_name(temp), reg_name(op1), operator, reg_name(op2));
}

void forTAC(int repeatLabel, int exitLabel) {

    // Swap position of Update and Body
    tac.last[tac.top -2]->next = tac.head[tac.top];
    tac.last[tac.top -2] = tac.last[tac.top];
    tac.last[tac.top] = tac.head[tac.top] = NULL;

    tac.last[tac.top -2]->next = tac.head[tac.top -1];
    tac.last[tac.top -2] = tac.last[tac.top -1];
    tac.last[tac.top -1] = tac.head[tac.top -1] = NULL;

    tac.top -= 2;

    curr_buff = get_buff_node();
    sprintf(curr_buff->code, "GOTO L%d", repeatLabel);
    curr_buff = get_buff_node();
    sprintf(curr_buff->code, "L%d", exitLabel);
}

void printTAC() {

    int lineno = 1;
    buffer_node *temp = tac.head[tac.top];

    printf("\n====== Three Address Code ======\n");
    while(temp != NULL) {
        printf("%5d. %s\n", lineno++, temp->code);
        temp = temp->next;
    }
    printf("================================\n");
}