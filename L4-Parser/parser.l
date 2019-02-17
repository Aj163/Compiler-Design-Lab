%option yylineno

number      [0-9]
letter      [a-zA-Z]
alphanum    [{letter}|{number}]

%%
\n          {}

int         { return INT; }
main        { return MAIN; }
for         { return FOR; }
return      { return RETURN; }

[_|{letter}][_|{alphanum}]* {

    yyval = yytext;
    return IDENTIFIER; 
}

#include[ ]*<[_|{letter}][_|{alphanum}]*>   { /* Header Files */ }

{number}+ {

    yyval = yytext;
    return INTEGER_CONSTANT; 
}

\"[.]*\" {

    yyval = yytext;
    return STRING_CONSTANT; 
}

[+|-|=|/|*|%|&|\(|\)|\[|\]|;|,]         { return *yytext; }
"/*"([.|\n]*[*]+[^/])*[.|\n]*[*]+"/"    { /* Multi Line Comment */ }

"++"                                    { return INCREMENT; }
"--"                                    { return DECREMENT; }

%%