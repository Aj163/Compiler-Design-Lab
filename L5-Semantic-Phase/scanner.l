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

int         { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return INT; }
char        { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return CHAR; }
main        { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return MAIN; }
for         { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return FOR; }
return      { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return RETURN; }
if          { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return IF; }
else        { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return ELSE; }
void        { yylval.str = malloc(100 * sizeof(char)); strcpy(yylval.str, yytext); return VOID; }

"#include"[ ]*"<"(_|{letter})(_|{alphanum})*".h>"  { 
    
    /* Header Files */
    print(yytext);
}

{number}+ {

    print(yytext);
    yylval.str = malloc(100 * sizeof(char)); 
    strcpy(yylval.str, yytext);
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

[+|\-|=|/|*|%|&|\(|\)|\[|\]|\;|,|\{|\}|<|>]  { print(yytext); return *yytext; }

"++"                                        { return INCREMENT; }
"--"                                        { return DECREMENT; }
"+="                                        { return PLUSEQ; }

(_|{letter})(_|{alphanum})* {

    print(yytext);
    yylval.str = malloc(100 * sizeof(char));
    strcpy(yylval.str, yytext);
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