#ifndef VARLIST_HEADER
#define VARLIST_HEADER

// Linked list that contains initialization of variable(s)
struct VarNode {
    char *var; // Name of a variable
    int val; // Value of a variable
    struct VarNode *next;
};

typedef struct VarNode VarNode;

VarNode* make_varlist(char *var, int val, VarNode *next);
int lookup_var(VarNode *head, char *var);
void free_varlist(VarNode *node);

#endif
