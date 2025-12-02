#ifndef VM_FRAME_H
#define VM_FRAME_H

#include <list.h>
#include "vm/page.h"

struct list frame_table;

struct lock evictLock;
struct lock tableLock;

struct frame_entry
{
    void *vas;
    void *pas;
    struct list_elem elem;
    struct thread *frameThread;
};

void ftInit();
struct frame_entry *frameAllocation(void *vad, void *pad);

void initFrame(struct frame_entry *frame, void *vad, void *pad, struct thread *fmTh);
void clearFrame(struct thread *page_dir, void *vad, void *pad);

bool frameEvict();

#endif