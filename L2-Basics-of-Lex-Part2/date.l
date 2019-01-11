/*
    Program to search for current date (dd-mm-yyyy)
*/

%{
    #include <stdio.h>

    #define YELLOW "\033[0;33m"
    #define BOLD_YELLOW "\033[1;33m"
    #define RESET "\033[0m"
%}

%%
"11-01-2019" {
    printf("%sToday's Date!%s\n", BOLD_YELLOW, RESET);
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