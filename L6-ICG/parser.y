%{
    #include "icg.c"
%}

%union {
    char *str;
    int intval;
}

%token <str> CHAR INT MAIN FOR RETURN IF ELSE VOID
%token <str> STRING_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token <str> INCREMENT DECREMENT PLUSEQ

%left '=' PLUSEQ
%left '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left INCREMENT DECREMENT

%type <str> DataType
%type <intval> ConstExpression ParamList ListOfParams ArgList Expression

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
    | IDENTIFIER '=' Expression ',' VarList                         { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '=' Expression                                     { redeclared($1); insert(yylineno, $1, type, curr_scope); }
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
    | Expression '<' Expression                             { lvalue_check($3); $$ = 0; }
    | Expression '>' Expression                             { lvalue_check($3); $$ = 0; }
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
    | Expression '*' Expression                             { lvalue_check($3); $$ = 0; }
    | Expression '/' Expression                             { lvalue_check($3); $$ = 0; }
    | Expression '%' Expression                             { lvalue_check($3); $$ = 0; }
    | IDENTIFIER '=' Expression                             { $$ = 1; }
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
    : DataType IDENTIFIER ParenthesisOpen ParamList ParenthesisClose CompundStat    { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope);
        temp->num_params = $4;
    }
    | DataType MAIN ParenthesisOpen ParamList ParenthesisClose CompundStat          { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope); 
        temp->num_params = $4;
    }
    | DataType IDENTIFIER ParenthesisOpen ParenthesisClose CompundStat              { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope);
        temp->num_params = 0;
    }
    | DataType MAIN ParenthesisOpen ParenthesisClose CompundStat                    { 
        redeclared($2); 
        node *temp = insert(yylineno, $2, $1, curr_scope); 
        temp->num_params = 0;
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
    | ReturnStat ';'
    | ';'
    | IfStat
    ;

IfStat
    : IF '(' Expression ')' CompundStat                     %prec IfWithoutElse
    | IF '(' Expression ')' SingleStat                      %prec IfWithoutElse
    | IF '(' Expression ')' CompundStat ELSE CompundStat    %prec ELSE
    | IF '(' Expression ')' SingleStat ELSE CompundStat     %prec ELSE
    | IF '(' Expression ')' CompundStat ELSE SingleStat     %prec ELSE
    | IF '(' Expression ')' SingleStat ELSE SingleStat      %prec ELSE

ForStat
    : FOR '(' VarDec ';' Expression ';' Expression ')' CompundStat
    | FOR '(' Expression ';' Expression ';' Expression ')' CompundStat
    | FOR '(' VarDec ';' Expression ';' Expression ')' SingleStat
    | FOR '(' Expression ';' Expression ';' Expression ')' SingleStat
    ;

ReturnStat
    : RETURN Expression
    | RETURN

FuncCall
    : IDENTIFIER '(' ArgList ')'                                                { not_declared($1); not_function($1); num_param_check($1, $3); }
    | IDENTIFIER '(' ')'                                                        { not_declared($1); not_function($1); num_param_check($1, 0);  }
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
    printf("\nSymbol Table\n");
    printSymbolTable();
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

*/