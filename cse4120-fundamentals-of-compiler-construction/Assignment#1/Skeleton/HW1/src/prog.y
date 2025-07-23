%define parse.error verbose

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "varlist.h"
extern FILE *yyin;
// To suppress warnings.
void yyerror(const char *s);
int yylex(void);
%}

/* Note: You will not have to fix the code above */

%union {
    int n;
    char *s;
    struct AST *a;
}

/* Declare tokens and types */
%token <n> NUM
%token <s> ID
%token PLUS MULT
%token SEMICOLON

%type <a> Exp Term Fact

%start Prog

%%

Prog:
 SEMICOLON Exp  { printf("%d\n", eval_ast(NULL, $2)); free_ast($2); }
;

Exp:
 Term               { $$ = $1; }
 | Exp PLUS Term    { $$ = make_binop_ast(Add, $1, $3); }
;

Term:
 Fact               { $$ = $1; }
 | Term MULT Fact   { $$ = make_binop_ast(Mul, $1, $3); }
;

Fact:
 NUM    { $$ = make_num_ast($1); }
 | ID   { $$ = make_id_ast($1); }
;

%%

/* Note: DO NOT TOUCH THE CODE BELOW */

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <input file>\n", argv[0]);
        exit(1);
    }

    if (NULL == (yyin = fopen(argv[1], "r"))) {
        printf("Failed to open %s\n", argv[1]);
        exit(1);
    }

    yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
}
