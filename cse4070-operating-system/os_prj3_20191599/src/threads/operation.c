#include "threads/operation.h"

int floatToFloat(int f1, int f2, char op)
{
    switch (op)
    {
    case '+':
        return f1 + f2;
    case '-':
        return f1 - f2;
    case '/':
        return f1 / f2;
    default:
        break;
    }

    int64_t tmp = f1;
    tmp *= f2;
    tmp /= FRACTION;
    return (int)tmp;
}

int intToFloat(int i, int f, char op)
{
    int fi = i * FRACTION;
    switch (op)
    {
    case '+':
        return fi + f;
    case '-':
        return fi - f;
    case '*':
        return i * f;
    case '/':
        f / i;
    }
    return -1;
}