%{
    #include "icg.c"
%}

%union {
    char *str;
    int intval;
}

%token <str> CHAR INT MAIN FOR RETURN IF ELSE VOID WHILE
%token <str> STRING_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token <str> INCREMENT DECREMENT PLUSEQ

%left '=' PLUSEQ
%left '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left INCREMENT DECREMENT

%type <str> DataType
%type <intval> ConstExpression ParamList ListOfParams ArgList Expression IfTAC ElseTAC
%type <intval> WhileBodyTAC WhileCondTAC

%nonassoc IfWithoutElse
%nonassoc ELSE

%%
Global
    : FunDec Global
    | FunDef Global
    | VarDec ';' Global
    |
    ;

FunDec
    : DataType IDENTIFIER ParenthesisOpen ParamList ParenthesisClose ';'    { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope); 
        temp->num_params = $4;
    }
    | DataType IDENTIFIER ParenthesisOpen ParenthesisClose ';'              { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope); 
        temp->num_params = 0;
    }
    ;

ParenthesisOpen
    : '('                                                                   { curr_scope++; } 
    ;

ParenthesisClose
    : ')'                                                                   { curr_scope--; }        
    ;

VarDec
    : DataType VarList
    ;

VarList
    : IDENTIFIER                                                    { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER ',' VarList                                        { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '[' ConstExpression ']'                            { arraySizeCheck($3, $1); redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '[' ConstExpression ']' ',' VarList                { arraySizeCheck($3, $1); redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '=' Expression                                     { 
        
            redeclared($1); 
            insert(yylineno, $1, type, curr_scope); 
            reg_node *op = pop(); 

            printf("%5d. ", tac_lineno++);
            printf("%s = ", $1);
            print_reg(op);
            printf("\n"); 
        }
        ',' VarList  
    | IDENTIFIER '=' Expression                                     { 
        
        redeclared($1); 
        insert(yylineno, $1, type, curr_scope); 
        reg_node *op = pop(); 

        printf("%5d. ", tac_lineno++);
        printf("%s = ", $1);
        print_reg(op);
        printf("\n"); 
    }
    ;

ConstExpression
    : INTEGER_CONSTANT                                      { $$ = atoi($1); }
    | ConstExpression '+' ConstExpression                   { $$ = $1 + $3; }
    | ConstExpression '-' ConstExpression                   { $$ = $1 - $3; }
    | ConstExpression '*' ConstExpression                   { $$ = $1 * $3; }
    | ConstExpression '/' ConstExpression                   { divByZero($3); $$ = $1 / $3; }
    | ConstExpression '%' ConstExpression                   { $$ = $1 % $3; }
    | ConstExpression '<' ConstExpression                   { $$ = $1 < $3; }
    | ConstExpression '>' ConstExpression                   { $$ = $1 > $3; }
    | '(' ConstExpression ')'                               { $$ = $2; }
    ;

Expression
    : Term                                                  { $$ = 0; }
    | Expression '+' Expression                             { 
        
        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" + ");
        print_reg(op2);
        printf("\n"); 
    }
    | Expression '<' Expression                             { 
        
        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" < ");
        print_reg(op2);
        printf("\n"); 
    }
    | Expression '>' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" > ");
        print_reg(op2);
        printf("\n"); 
    }
    | Expression '-' Expression                             { 
        
        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" - ");
        print_reg(op2);
        printf("\n");
    }
    | Expression '*' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" + ");
        print_reg(op2);
        printf("\n"); 
    }
    | Expression '/' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" / ");
        print_reg(op2);
        printf("\n"); 
    }
    | Expression '%' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        reg_node *op2 = pop(), *op1 = pop(), *temp = newNode("t", ++t_ctr); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op1);
        printf(" %% ");
        print_reg(op2);
        printf("\n"); 
    }
    | IDENTIFIER '=' Expression                             { 
        
        $$ = 1; 
        reg_node *op = pop(), *temp = newNode($1, -1); 
        icg_stack[++icg_tos] = temp; 

        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = ");
        print_reg(op);
        printf("\n"); 
    }
    | Expression PLUSEQ Expression                          { $$ = 1; }
    | '(' Expression ')'                                    { $$ = 0; }
    ;

Term
    : IDENTIFIER                                                { not_declared($1); reg_node *temp = newNode($1, -1); icg_stack[++icg_tos] = temp; }
    | INCREMENT IDENTIFIER                                      { not_declared($2); }
    | IDENTIFIER INCREMENT                                      { not_declared($1); }
    | DECREMENT IDENTIFIER                                      { not_declared($2); }
    | IDENTIFIER DECREMENT                                      { not_declared($1); }
    | INTEGER_CONSTANT                                          { reg_node *temp = newNode($1, -1); icg_stack[++icg_tos] = temp; }
    | FLOAT_CONSTANT
    | STRING_CONSTANT
    | FuncCall
    ;

ListOfParams
    : DataType IDENTIFIER ',' ListOfParams                      { $$ = $4 +1;   voidCheck($1); redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType IDENTIFIER                                       { $$ = 1;       voidCheck($1); redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    ;

ParamList
    : VOID                                                      { $$ = 0;  }
    | ListOfParams                                              { $$ = $1; }
    ;

DataType
    : INT                                                       { strcpy($$, $1); strcpy(type, $1); }
    | CHAR                                                      { strcpy($$, $1); strcpy(type, $1); }
    | VOID                                                      { strcpy($$, $1); strcpy(type, $1); }
    ;

FunDef
    : DataType IDENTIFIER ParenthesisOpen ParamList ParenthesisClose {
            printf("\nFUNCTION %s BEGIN\n", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope);
            temp->num_params = $4;
            printf("END %s\n", $2);
            tac_lineno = 1;
        }
    | DataType MAIN ParenthesisOpen ParamList ParenthesisClose {
            printf("\nFUNCTION %s BEGIN\n", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope); 
            temp->num_params = $4;
            printf("END %s\n", $2);
            tac_lineno = 1;
        }
    | DataType IDENTIFIER ParenthesisOpen ParenthesisClose {
            printf("\nFUNCTION %s BEGIN\n", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope);
            temp->num_params = 0;
            printf("END %s\n", $2);
            tac_lineno = 1;
        }
    | DataType MAIN ParenthesisOpen ParenthesisClose {
            printf("\nFUNCTION %s BEGIN\n", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope); 
            temp->num_params = 0;
            printf("END %s\n", $2);
            tac_lineno = 1;
        }
    ;

CompundStat
    :   '{'                                                                         { curr_scope++; }
        StatList
        '}'                                                                         {
            while(stack[tos]->scope == curr_scope)
                tos--;
            curr_scope--;
        }

StatList
    : SingleStat StatList
    | CompundStat StatList
    |
    ;

SingleStat
    : Expression ';'
    | VarDec ';'
    | ForStat
    | WhileStat
    | ReturnStat ';'
    | ';'
    | IfStat
    ;

WhileStat
    : WHILE WhileCondTAC '(' Expression ')' WhileBodyTAC CompundStat        { printf("%5d. GOTO L%d\nL%d", tac_lineno++, $2, $6); printf(":\n"); }
    | WHILE WhileCondTAC '(' Expression ')' WhileBodyTAC SingleStat         { printf("%5d. GOTO L%d\nL%d", tac_lineno++, $2, $6); printf(":\n"); }
    ;

WhileCondTAC
    : {
        printf("L%d", label_num);
        printf(":\n");
        $$ = label_num++;
    }
    ;

WhileBodyTAC
    : {
        reg_node *op = pop();
        reg_node *temp = newNode("t", ++t_ctr);
        
        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = NOT ");
        print_reg(op);

        printf("\n%5d. IF ", tac_lineno++);
        print_reg(temp);
        printf(" GOTO L%d\n", label_num);

        $$ = label_num++;
        t_ctr--;
    }
    ;

IfStat
    : IF '(' Expression ')' IfTAC CompundStat                               { printf("L%d", $5); printf(":\n"); } %prec IfWithoutElse
    | IF '(' Expression ')' IfTAC SingleStat                                { printf("L%d", $5); printf(":\n"); } %prec IfWithoutElse
    | IF '(' Expression ')' IfTAC CompundStat ELSE ElseTAC                  { printf("L%d", $5); printf(":\n"); } 
        CompundStat                                                         { printf("L%d", $8); printf(":\n"); } %prec ELSE
    | IF '(' Expression ')' IfTAC SingleStat  ELSE ElseTAC                  { printf("L%d", $5); printf(":\n"); } 
        CompundStat                                                         { printf("L%d", $8); printf(":\n"); } %prec ELSE
    | IF '(' Expression ')' IfTAC CompundStat ELSE ElseTAC                  { printf("L%d", $5); printf(":\n"); }
        SingleStat                                                          { printf("L%d", $8); printf(":\n"); } %prec ELSE
    | IF '(' Expression ')' IfTAC SingleStat  ELSE ElseTAC                  { printf("L%d", $5); printf(":\n"); }
        SingleStat                                                          { printf("L%d", $8); printf(":\n"); } %prec ELSE
    ;

IfTAC
    : {
        reg_node *op = pop();
        reg_node *temp = newNode("t", ++t_ctr);
        
        printf("%5d. ", tac_lineno++);
        print_reg(temp);
        printf(" = NOT ");
        print_reg(op);

        printf("\n%5d. IF ", tac_lineno++);
        print_reg(temp);
        printf(" GOTO L%d\n", label_num);

        $$ = label_num++;
        t_ctr--;
    }
    ;

ElseTAC
    : {
        printf("%5d. GOTO L%d\n", tac_lineno++, label_num);
        $$ = label_num++;
    }
    ;

ForStat
    : FOR '(' VarDec ';' Expression ';' Expression ')' CompundStat
    | FOR '(' Expression ';' Expression ';' Expression ')' CompundStat
    | FOR '(' VarDec ';' Expression ';' Expression ')' SingleStat
    | FOR '(' Expression ';' Expression ';' Expression ')' SingleStat
    ;

ReturnStat
    : RETURN Expression {
        printf("%5d. RETURN ", tac_lineno++);
        reg_node *op = pop();
        print_reg(op);
        printf("\n");

    }
    | RETURN {
        printf("%5d. RETURN\n", tac_lineno++);
    }

FuncCall
    : IDENTIFIER '(' ArgList ')' { 
        
        not_declared($1); 
        not_function($1); 
        num_param_check($1, $3); 
        
        print_arg_list($3);
        printf("%5d. CALL %s, %d\n", tac_lineno++, $1, $3);
    }
    | IDENTIFIER '(' ')' { 
        
        not_declared($1); 
        not_function($1); 
        num_param_check($1, 0); 

        printf("%5d. CALL %s\n", tac_lineno++, $1);
    }
    ;

ArgList
    : Expression ',' ArgList                                                    { $$ = $3 + 1; }
    | Expression                                                                { $$ = 1;      }
    ;
%%

int main() {

    tos++;
    node *dummy = malloc(sizeof(node));
    dummy->scope = -1;
    stack[tos] = dummy;

    printf("\n====== Three Address Code ======\n");
    yyparse();
    printf("================================\n");
    // printf("\nSymbol Table\n");
    // printSymbolTable();
}

/*

Semantic Errors
- Redeclaration
- Not declared
- Array size evaluation
- Void parameters
- Not a function
- Number of parameters do not match
- LHS of assignment should be a single variable

ICG
- If 
- If Else
- Expressions
- Variable initialization
- Function call
- Function name

*/