%{
    #include "y.tab.h"

    #define true 1
    #define false 0
    #define DEBUGGER false

    void print(char s[]) {
        
        if(DEBUGGER)
            printf("%d. %s\n", yylineno, s);
    }
%}

%option yylineno

number      [0-9]
letter      [a-zA-Z]
alphanum    ({letter}|{number})

%%
[\n|" "|\t] { 
    // print("White Space"); 
}

int         { yylval = malloc(100 * sizeof(char)); strcpy(yylval, yytext); return INT; }
main        { yylval = malloc(100 * sizeof(char)); strcpy(yylval, yytext); return MAIN; }
for         { yylval = malloc(100 * sizeof(char)); strcpy(yylval, yytext); return FOR; }
return      { yylval = malloc(100 * sizeof(char)); strcpy(yylval, yytext); return RETURN; }

"#include"[ ]*"<"(_|{letter})(_|{alphanum})*".h>"  { 
    
    /* Header Files */
    print(yytext);
}

{number}+ {

    print(yytext);
    return INTEGER_CONSTANT; 
}

({number}+"."{number}*)|({number}*"."{number}+) {

    print(yytext);
    return FLOAT_CONSTANT; 
}

\"[^"\n]*\" {

    print(yytext);
    return STRING_CONSTANT; 
}

"/*"([^*]*[*]+[^/])*[^*]*[*]+"/"            { /* Multi Line Comment */  print("Multi Line Comment"); }
"//"[^\n]*                                  { /* Single Line Comment */ print("Single Line Comment");}

[+|-|=|/|*|%|&|\(|\)|\[|\]|\;|,|\{|\}|<|>]  { print(yytext); return *yytext; }

"++"                                        { return INCREMENT; }
"--"                                        { return DECREMENT; }
"+="                                        { return PLUSEQ; }

(_|{letter})(_|{alphanum})* {

    yylval = malloc(100 * sizeof(char));
    strcpy(yylval, yytext);
    return IDENTIFIER; 
}

({number})(_|{alphanum})* {

    printf("Line %d : Invalid Identifier\n", yylineno);
    exit(0);
}

%%

int yywrap(void) {

    return 1;
}