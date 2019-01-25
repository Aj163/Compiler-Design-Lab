%{
#include<ctype.h>
#include<stdio.h>
#include<math.h>
#define YYSTYPE double

int yylex(void); 
void yyerror (char * s);
%}

%token NUM
%left '+' '-'
%left '*' '/' '%'
%right '^'
%right UMINUS

%%

S : S E '\n' { printf("Answer: %g\n\nEnter the expression : ", $2); }
    | S '\n'
    |
    | error '\n' { yyerror("Error: Enter once more...\n" );yyerrok; }
    ;

E : E '+' E { $$ = $1 + $3; }
    | E'-'E { $$=$1-$3; }
    | E'*'E { $$=$1*$3; }
    | E'%'E { $$=fmod($1, $3); }
    | E'/'E { $$=$1/$3; }
    | E'^'E { $$=pow($1, $3); }
    | '('E')' { $$=$2; }
    | '-'E %prec UMINUS { $$= -$2; }
    | NUM
    ;
%%

#include "lex.yy.c"

int main()
{
printf("Enter the expression : ");
yyparse();
}

void yyerror (char * s)
{
printf ("%s \n", s);
exit (1);
}