#include "symbol_table.c"

typedef struct {

    char name[100];
    int reg_num;
} reg_node;

reg_node *icg_stack[MOD];
int icg_tos = -1;
int t_ctr = -1;
int tac_lineno = 1;
int label_num = 1;

void print_reg(reg_node *temp) {

    printf("%s", temp->name);
    if(temp->reg_num != -1)
        printf("%d", temp->reg_num);
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
    printf("%5d. PARAM ", tac_lineno++);
    print_reg(temp);
    printf("\n");
}