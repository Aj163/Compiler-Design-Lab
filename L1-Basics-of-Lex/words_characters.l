/*
    Program to count the number of characters, words, spaces and newlines in a given string.
*/

%{
    #include <stdio.h>
    int chr=0, words=0, spaces=0;
    int isPrevChar = 0;
%}

%%
[" "] {
    spaces++;
    if(isPrevChar)
            isPrevChar = 0;
}
([a-zA-Z0-9]) {
    if(isPrevChar == 0) {
            isPrevChar = 1;
            words++;
    }
    chr++;
}
"\n" {
    printf("Words : %d\nCharacters : %d\nSpaces : %d\n", words, chr, spaces);
    words = spaces = chr = isPrevChar = 0;
}
%%

int yywrap() {}

int main() {

    yylex();
}
