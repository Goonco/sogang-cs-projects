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
    struct VarNode *v;
}

/* Declare tokens and types */
%token <n> NUM
%token <s> ID
%token PLUS MULT MINUS DIV
%token SEMICOLON
%token COMMA
%token PARENTHESIS1 PARENTHESIS2
%token ASSIGN

%type <a> Exp Term Fact
%type <v> Init

%start Prog

%%

Prog:
 SEMICOLON Exp  { printf("%d\n", eval_ast(NULL, $2)); free_ast($2); }
 | Init SEMICOLON Exp { printf("%d\n", eval_ast($1, $3)); free_ast($3); free_varlist($1); }
;

Init:
 ID ASSIGN NUM               { $$ = make_varlist($1,$3,NULL); }
 | ID ASSIGN NUM COMMA Init  { $$ = make_varlist($1, $3, $5); }
;

Exp:
 Term               { $$ = $1; }
 | Exp PLUS Term    { $$ = make_binop_ast(Add, $1, $3); }
 | Exp MINUS Term   { $$ = make_binop_ast(Sub, $1, $3); }
;

Term:
 Fact               { $$ = $1; }
 | Term MULT Fact   { $$ = make_binop_ast(Mul, $1, $3); }
 | Term DIV Fact    { $$ = make_binop_ast(Div, $1, $3); }
;

Fact:
 NUM    { $$ = make_num_ast($1); }
 | ID   { $$ = make_id_ast($1); }
 | PARENTHESIS1 Exp PARENTHESIS2  { $$ = $2; }
 | MINUS Fact { $$ = make_neg_ast($2); }
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
