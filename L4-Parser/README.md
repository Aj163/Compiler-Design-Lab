# Compile
`$ lex parser.l` <br>
Use the -d option to generate the `y.tab.h` file<br>
`$ yacc parser.y -d` <br>
`$ gcc y.tab.c`
