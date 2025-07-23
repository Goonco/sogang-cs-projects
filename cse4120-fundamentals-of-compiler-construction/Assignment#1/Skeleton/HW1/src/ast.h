#ifndef AST_HEADER
#define AST_HEADER

#include "varlist.h"

typedef enum {
    Number,
    Identifier,
    Add,
    Sub,
    Mul,
    Div,
    Neg
} NODE_KIND;

struct AST {
    NODE_KIND kind;
    // 'num' has meaning only when kind = Number
    int num;
    // 'id' has meaning only when kind = Identifier
    char *id;
    // Two childs have meaning only when kind = Add|Sub|Mul|Div
    // Only left child has meaning when kind = Neg
    struct AST *left;
    struct AST *right;
};

typedef struct AST AST;

AST* make_num_ast(int n);
AST* make_id_ast(char *s);
AST* make_binop_ast(NODE_KIND kind, AST *oprnd_1, AST *oprnd_2);
AST* make_neg_ast(AST *oprnd);
int eval_ast(VarNode *vars, AST* ast);
void free_ast(AST* ast);

#endif
