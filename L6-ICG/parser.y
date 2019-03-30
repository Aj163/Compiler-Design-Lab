%{
    #include "icg.c"
%}

%union {
    char *str;
    int intval;
}

%token <str> CHAR INT MAIN FOR RETURN IF ELSE VOID WHILE
%token <str> STRING_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token <str> INCREMENT DECREMENT PLUSEQ CONTINUE BREAK

%left '=' PLUSEQ
%left '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left INCREMENT DECREMENT

%type <str> DataType
%type <intval> ConstExpression ParamList ListOfParams ArgList Expression IfTAC ElseTAC
%type <intval> WhileBodyTAC WhileCondTAC ForCondExit ForCondLabel

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

            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "%s = %s", $1, reg_name(op));
        }
        ',' VarList  

    | IDENTIFIER '=' Expression                                     { 
        
        redeclared($1); 
        insert(yylineno, $1, type, curr_scope); 
        reg_node *op = pop(); 

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "%s = %s", $1, reg_name(op)); 
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
        exprTAC("+");
    }
    | Expression '<' Expression                             { 
        
        lvalue_check($3); 
        $$ = 0; 
        exprTAC("<");
    }
    | Expression '>' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        exprTAC(">"); 
    }
    | Expression '-' Expression                             { 
        
        lvalue_check($3); 
        $$ = 0; 
        exprTAC("-");
    }
    | Expression '*' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        exprTAC("*");
    }
    | Expression '/' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        exprTAC("/");
    }
    | Expression '%' Expression                             { 

        lvalue_check($3); 
        $$ = 0; 
        exprTAC("%");
    }
    | IDENTIFIER '=' Expression                             { 
        
        $$ = 1; 
        reg_node *op = pop(), *temp = newNode($1, -1); 
        icg_stack[++icg_tos] = temp; 

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "%s = %s", reg_name(temp), reg_name(op));
    }
    | Expression PLUSEQ Expression                          { $$ = 1; }
    | '(' Expression ')'                                    { $$ = 0; }
    | '-' Expression                                        { $$ = 0; }
    | '+' Expression                                        { $$ = 0; }
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
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "FUNCTION %s BEGIN", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope);
            temp->num_params = $4;
            
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "END %s", $2);
        }
    | DataType MAIN ParenthesisOpen ParamList ParenthesisClose {
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "FUNCTION %s BEGIN", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope); 
            temp->num_params = $4;
            
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "END %s", $2);
        }
    | DataType IDENTIFIER ParenthesisOpen ParenthesisClose {
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "FUNCTION %s BEGIN", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope);
            temp->num_params = 0;
            
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "END %s", $2);
        }
    | DataType MAIN ParenthesisOpen ParenthesisClose {
            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "FUNCTION %s BEGIN", $2);
        } 
        CompundStat { 
            redeclared($2); 
            node *temp = insert(yylineno, $2, $1, curr_scope); 
            temp->num_params = 0;

            curr_buff = get_buff_node();
            sprintf(curr_buff->code, "END %s", $2);
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
    : Expression ';' { pop(); }
    | VarDec ';'
    | ForStat
    | WhileStat
    | ReturnStat ';'
    | ';'
    | IfStat
    | CONTINUE ';' {
        if(continueStack.top == -1) {
            printf("Line %d : a continue statement may only be used within a loop\n", yylineno);
            exit(1);
        }
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "GOTO L%d", continueStack.label[continueStack.top]);
    }
    | BREAK ';' {
        if(breakStack.top == -1) {
            printf("Line %d : a break statement may only be used within a loop\n", yylineno);
            exit(1);
        }
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "GOTO L%d", breakStack.label[breakStack.top]);
    }
    ;

WhileStat
    : WHILE WhileCondTAC '(' Expression ')' WhileBodyTAC CompundStat        { 
        
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "GOTO L%d", $2);
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "L%d", $6);
    }
    | WHILE WhileCondTAC '(' Expression ')' WhileBodyTAC SingleStat         { 
        
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "GOTO L%d", $2);
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "L%d", $6);
    }
    ;

WhileCondTAC
    : {
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "L%d", label_num);
        continueStack.label[++continueStack.top] = label_num;
        $$ = label_num++;
    }
    ;

WhileBodyTAC
    : {
        reg_node *op = pop();
        reg_node *temp = newNode("t", ++t_ctr);

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "%s = NOT %s", reg_name(temp), reg_name(op));
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "IF %s GOTO L%d", reg_name(temp), label_num);

        breakStack.label[++breakStack.top] = label_num;
        $$ = label_num++;
        t_ctr--;
    }
    ;

IfStat
    : IF '(' Expression ')' IfTAC CompundStat                               { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); } %prec IfWithoutElse
    | IF '(' Expression ')' IfTAC SingleStat                                { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); } %prec IfWithoutElse
    | IF '(' Expression ')' IfTAC CompundStat ELSE ElseTAC                  { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); }
        CompundStat                                                         { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $8); } %prec ELSE
    | IF '(' Expression ')' IfTAC SingleStat  ELSE ElseTAC                  { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); } 
        CompundStat                                                         { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $8); } %prec ELSE
    | IF '(' Expression ')' IfTAC CompundStat ELSE ElseTAC                  { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); }
        SingleStat                                                          { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $8); } %prec ELSE
    | IF '(' Expression ')' IfTAC SingleStat  ELSE ElseTAC                  { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $5); }
        SingleStat                                                          { curr_buff = get_buff_node(); sprintf(curr_buff->code, "L%d", $8); } %prec ELSE
    ;

IfTAC
    : {
        reg_node *op = pop();
        reg_node *temp = newNode("t", ++t_ctr);

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "%s = NOT %s", reg_name(temp), reg_name(op));

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "IF %s GOTO L%d", reg_name(temp), label_num);
        
        $$ = label_num++;
        t_ctr--;
    }
    ;

ElseTAC
    : {
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "GOTO L%d", label_num);
        $$ = label_num++;
    }
    ;

ForStat
    : FOR '(' VarDec     ';' ForCondLabel Expression ';' ForCondExit Expression ')' { tac.top++; } CompundStat  { forTAC($5, $8); }
    | FOR '(' Expression ';' ForCondLabel Expression ';' ForCondExit Expression ')' { tac.top++; } CompundStat  { forTAC($5, $8); }
    | FOR '(' VarDec     ';' ForCondLabel Expression ';' ForCondExit Expression ')' { tac.top++; } SingleStat   { forTAC($5, $8); }
    | FOR '(' Expression ';' ForCondLabel Expression ';' ForCondExit Expression ')' { tac.top++; } SingleStat   { forTAC($5, $8); }
    ;

ForCondLabel
    : {
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "L%d", label_num);
        continueStack.label[++continueStack.top] = label_num;
        $$ = label_num++;
    }
    ;

ForCondExit
    : {
        reg_node *temp = pop();
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "IF NOT %s GOTO L%d", reg_name(temp), label_num);
        breakStack.label[++breakStack.top] = label_num;
        $$ = label_num++;
        tac.top++;
    }

ReturnStat
    : RETURN Expression {

        reg_node *op = pop();
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "RETURN %s", reg_name(op));
    }
    | RETURN {
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "RETURN");
    }

FuncCall
    : IDENTIFIER '(' ArgList ')' { 
        
        not_declared($1); 
        not_function($1); 
        num_param_check($1, $3); 

        print_arg_list($3);
        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "CALL %s, %d", $1, $3);
    }
    | IDENTIFIER '(' ')' { 
        
        not_declared($1); 
        not_function($1); 
        num_param_check($1, 0); 

        curr_buff = get_buff_node();
        sprintf(curr_buff->code, "CALL %s", $1);
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

    tac.top = 0;
    tac.head[tac.top] = NULL;
    tac.last[tac.top] = NULL;

    continueStack.top = -1;
    breakStack.top = -1;

    yyparse();
    // printSymbolTable();
    printTAC();
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
- For Loop

*/