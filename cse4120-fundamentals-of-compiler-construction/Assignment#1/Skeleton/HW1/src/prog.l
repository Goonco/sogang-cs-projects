%option noyywrap

%{
#include "prog.tab.h"
%}

dig [0-9]
let [A-Za-z]

%%

"+"                         { return PLUS; }
"*"                         { return MULT; }
";"                         { return SEMICOLON; }
{dig}+                      { yylval.n = atoi(yytext); return NUM; }
({let}|_)({let}|{dig}|_)*   { yylval.s = strdup(yytext); return ID; }
[ \t\n]+                    { /* Skip whitespace. */ }
.                           { /* Wildcard '.' that matches anything */
                              printf("Invalid token: %s\n", yytext);
                              exit(1);
                            }

%%
