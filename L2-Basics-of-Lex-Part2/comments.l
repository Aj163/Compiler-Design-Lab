/*
    Program to search for single and multiline comments
*/

%{
    #include <stdio.h>
    
    #define MAGENTA "\033[0;35m"
    #define BOLD_MAGENTA "\033[1;35m"
    #define YELLOW "\033[0;33m"
    #define BOLD_YELLOW "\033[1;33m"
    #define RESET "\033[0m"
%}

%%
("//")(.)*("\n") {
    printf("%s--- Single Line Comment ---\n%s%s%s", BOLD_MAGENTA, MAGENTA, yytext, RESET);
}
("/*")(([^*]*[*]+[^*/])*([^*]*[*]+[/]))  {
    printf("%s--- Multi Line Comment ---\n%s%s%s\n", BOLD_YELLOW, YELLOW, yytext, RESET);
}
(.|"\n") {}
%%

int yywrap() {}

int main(int argc, char **argv) {

    if(argc == 2) {
        freopen(argv[1], "r", stdin);
    }
    yylex();
}