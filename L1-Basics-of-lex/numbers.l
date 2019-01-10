/*
    Program to count the number of positive and negative numbers and fractions.
*/

%{
    #include <stdio.h>
%}

%%
([0])*[1-9]([0-9])* {
    printf("Positive number\n");
}
[-]([0])*[1-9]([0-9])* {
    printf("Negative number\n");
}

([0-9])*[1-9]([0-9])*[.]([0-9])* {
    printf("Positive fraction\n");
}
([0-9])*[.]([0-9])*[1-9]([0-9])* {
    printf("Positive fraction\n");
}

[-]([0-9])*[1-9]([0-9])*[.]([0-9])* {
    printf("Negative fraction\n");
}
[-]([0-9])*[.]([0-9])*[1-9]([0-9])* {
    printf("Negative fraction\n");
}
%%

int yywrap() {}

int main() {

    yylex();
}
