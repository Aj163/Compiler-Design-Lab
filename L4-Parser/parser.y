%{
    #include "symbol_table.c"
    #define YYSTYPE char*
    #include "lex.yy.c"

    extern int yylineno;
    void yyerror(char *s) {

        fprintf(stderr, "%s\n", s);
    }
    char type[100];
%}

%token INT MAIN FOR RETURN IF ELSE
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
    | INCREMENT IDENTIFIER
    | IDENTIFIER INCREMENT
    | DECREMENT IDENTIFIER
    | IDENTIFIER DECREMENT
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
    : DataType IDENTIFIER '(' ParamList ')' CompundStat             { insert(yylineno, $2, type); }
    | DataType MAIN '(' ParamList ')' CompundStat                   { insert(yylineno, $2, type); }
    | DataType IDENTIFIER '(' ')' CompundStat                       { insert(yylineno, $2, type); }
    | DataType MAIN '(' ')' CompundStat                             { insert(yylineno, $2, type); }
    ;

CompundStat
    : '{' StatList '}'

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
    | IF '(' Expression ')' SingleStat                     %prec IfWithoutElse
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

    yyparse();
    printSymbolTable();
}