#ifndef VM_SWAP_H
#define VM_SWAP_H

void swapInit();

void swapIn(void *vad, void *pad, int swapI);
int32_t swapOut(void *pad);

#endif