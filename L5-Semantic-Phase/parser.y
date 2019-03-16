%{
    #include "symbol_table.c"
%}

%token CHAR INT MAIN FOR RETURN IF ELSE
%token STRING_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token INCREMENT DECREMENT PLUSEQ

%left '>' '<' '=' PLUSEQ
%left '+' '-'
%left '*' '/' '%'
%left INCREMENT DECREMENT

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
    : DataType IDENTIFIER ParanthesisOpen ParamList ParanthesisClose ';'    { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType IDENTIFIER ParanthesisOpen ParanthesisClose ';'              { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    ;

ParanthesisOpen
    : '('                                                                   { curr_scope++; } 
    ;

ParanthesisClose
    : ')'                                                                   { curr_scope--; }        
    ;

VarDec
    : DataType VarList
    ;

VarList
    : IDENTIFIER                                                    { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER ',' VarList                                        { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '=' Expression ',' VarList                         { redeclared($1); insert(yylineno, $1, type, curr_scope); }
    | IDENTIFIER '=' Expression                                     { redeclared($1); insert(yylineno, $1, type, curr_scope); }
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
    : IDENTIFIER                                                { not_declared($1); }
    | INCREMENT IDENTIFIER                                      { not_declared($2); }
    | IDENTIFIER INCREMENT                                      { not_declared($1); }
    | DECREMENT IDENTIFIER                                      { not_declared($2); }
    | IDENTIFIER DECREMENT                                      { not_declared($1); }
    | INTEGER_CONSTANT
    | FLOAT_CONSTANT
    | STRING_CONSTANT
    | FuncCall
    ;

ParamList
    : DataType IDENTIFIER ',' ParamList                                             { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType IDENTIFIER                                                           { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    ;

DataType
    : INT                                                                           { strcpy($$, $1); strcpy(type, $1); }
    | CHAR                                                                          { strcpy($$, $1); strcpy(type, $1); }
    ;

FunDef
    : DataType IDENTIFIER ParanthesisOpen ParamList ParanthesisClose CompundStat    { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType MAIN ParanthesisOpen ParamList ParanthesisClose CompundStat          { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType IDENTIFIER ParanthesisOpen ParanthesisClose CompundStat              { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    | DataType MAIN ParanthesisOpen ParanthesisClose CompundStat                    { redeclared($2); insert(yylineno, $2, $1, curr_scope); }
    ;

CompundStat
    : '{'                                                                           { curr_scope++; }
        StatList
        '}' {
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
    : IDENTIFIER '(' ArgList ')'
    | IDENTIFIER '(' ')'
    ;

ArgList
    : Expression ',' ArgList
    | Expression
    ;
%%

int main() {

    tos++;
    node *dummy = malloc(sizeof(node));
    dummy->scope = -1;
    stack[tos] = dummy;

    yyparse();
    printSymbolTable();
}