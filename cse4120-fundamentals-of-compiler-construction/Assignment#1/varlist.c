#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "varlist.h"

// TODO: Fill in
VarNode *make_varlist(char *var, int val, VarNode *next)
{
    VarNode *node = (VarNode *)malloc(sizeof(VarNode));
    node->var = var;
    node->val = val;
    node->next = next;
    return node;
}

// TODO: Fill in
int lookup_var(VarNode *head, char *var)
{
    VarNode *iter = head;
    while (iter != NULL)
    {
        if (strcmp(iter->var, var) == 0)
            return iter->val;
        iter = iter->next;
    }

    printf("MyError : No %s in lookup_var\n", var);
    return -1;
}

// TODO: Fill in
void free_varlist(VarNode *head)
{
    // printf("Unimplemented: free_varlist()\n");
    VarNode *tmp;
    while (head != NULL)
    {
        tmp = head;
        head = head->next;
        free(tmp);
    }
    return;
}
