lex scanner.l
yacc parser.y -d
gcc y.tab.c
./a.out