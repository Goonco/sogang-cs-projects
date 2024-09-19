#include <stdio.h>
#include <stdlib.h>
#include "varlist.h"
#include "ast.h"

AST *make_num_ast(int n)
{
    AST *ast = (AST *)malloc(sizeof(AST));
    ast->kind = Number;
    ast->num = n;
    ast->id = NULL;
    ast->left = NULL;
    ast->right = NULL;
    return ast;
}

AST *make_id_ast(char *s)
{
    AST *ast = (AST *)malloc(sizeof(AST));
    ast->kind = Identifier;
    ast->num = 0;
    ast->id = s;
    ast->left = NULL;
    ast->right = NULL;
    return ast;
}

AST *make_binop_ast(NODE_KIND kind, AST *oprnd_1, AST *oprnd_2)
{
    AST *ast = (AST *)malloc(sizeof(AST));
    ast->kind = kind;
    ast->num = 0;
    ast->id = NULL;
    ast->left = oprnd_1;
    ast->right = oprnd_2;
    return ast;
}

// TODO: Fill in
AST *make_neg_ast(AST *oprnd)
{
    AST *ast = (AST *)malloc(sizeof(AST));
    ast->kind = Neg;
    ast->num = 0;
    ast->id = NULL;
    ast->left = oprnd;
    ast->right = NULL;
    return ast;
}

// TODO: Fill in
int eval_ast(VarNode *vars, AST *ast)
{
    // print_varlist(vars);
    // print_ast(ast);
    // return 1;

    if (ast == NULL)
        return 0;

    int left, right;
    left = eval_ast(vars, ast->left);
    right = eval_ast(vars, ast->right);

    int ret;
    switch (ast->kind)
    {
    case Number:
        ret = ast->num;
        break;
    case Add:
        ret = left + right;
        break;
    case Sub:
        ret = left - right;
        break;
    case Mul:
        ret = left * right;
        break;
    case Div:
        ret = left / right;
        break;
    case Identifier:
        ret = lookup_var(vars, ast->id);
        break;
    case Neg:
        ret = -1 * left;
        break;
    default:
        printf("MyError : No case in eval_ast\n");
    }

    return ret;
}

void print_varlist(VarNode *root)
{
    VarNode *iter = root;
    while (iter != NULL)
    {
        printf("@@@%s %d\n", iter->var, iter->val);
        iter = iter->next;
    }
}

void print_ast(AST *ast)
{
    if (ast->kind == Add)
        printf("+\n");
    else if (ast->kind == Mul)
        printf("*\n");
    else if (ast->kind == Sub)
        printf("-\n");
    else if (ast->kind == Identifier)
        printf("%s\n", ast->id);
    else
        printf("%d\n", ast->num);

    if (ast->left != NULL)
    {
        printf("Left : ");
        print_ast(ast->left);
    }
    if (ast->right != NULL)
    {
        printf("Right : ");
        print_ast(ast->right);
    }
}

void free_ast(AST *ast)
{
    switch (ast->kind)
    {
    case Number:
        break;
    case Identifier:
        free(ast->id);
        break;
    case Add:
    case Sub:
    case Mul:
    case Div:
        free_ast(ast->left);
        free_ast(ast->right);
        break;
    case Neg:
        free_ast(ast->left);
        break;
    }
    free(ast);
}

// -------------------------- Stack Code

// #define MAX_STACK_SIZE 10000

// typedef struct StackNode
// {
//     struct AST *data;
//     struct StackNode *next;
// } StackNode;

// typedef struct
// {
//     StackNode *top;
// } Stack;

// void initStack(Stack *st)
// {
//     st->top = NULL;
// }

// int isEmpty(Stack *st)
// {
//     return (st->top == NULL);
// }

// void push(Stack *st, AST *data)
// {
//     StackNode *newNode = (StackNode *)malloc(sizeof(StackNode));
//     newNode->data = data;
//     newNode->next = st->top;
//     st->top = newNode;
// }

// AST *pop(Stack *st)
// {
//     StackNode *topNode = st->top;
//     struct AST *data = topNode->data;

//     st->top = topNode->next;
//     free(topNode);
//     return data;
// }

// AST *peek(Stack *st)
// {
//     return st->top;
// }