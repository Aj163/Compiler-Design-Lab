/*      
    Program to count the number of vowels and no of consonants in a given string.
*/

%{
#include <stdio.h>
#include <string.h>

int i=0, j=0;
%}

%%
[aieouAEIOU] {i++;}
"\n" {printf("Vowels : %d\nConsonants : %d\n", i, j); i=0; j=0;}
[^(aieouAEIOU)] {j++;}
%%

int yywrap() {}

int main() {

    yylex();
    return 0;
}
