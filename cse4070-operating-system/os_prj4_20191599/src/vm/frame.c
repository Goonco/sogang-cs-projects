#include <stdio.h>
#include <stdlib.h>

#include "threads/thread.h"
#include "threads/palloc.h"
#include "threads/vaddr.h"

#include "vm/page.h"
#include "vm/frame.h"
#include "vm/swap.h"

static struct list_elem *currentLRU;

void ftInit()
{
    lock_init(&tableLock);
    lock_init(&evictLock);
    list_init(&frame_table);
    currentLRU = NULL;
}

void initFrame(struct frame_entry *frame, void *vad, void *pad, struct thread *fmTh)
{
    frame->vas = pg_round_down(vad);
    frame->pas = pg_round_down(pad);
    frame->frameThread = fmTh;
}

struct frame_entry *frameAllocation(void *vad, void *pad)
{
    struct frame_entry *frame = (struct frame_entry *)malloc(sizeof(struct frame_entry));
    struct thread *curThread = thread_current();

    if (pad != NULL)
    {
        initFrame(frame, pg_round_down(vad), pg_round_down(pad), curThread);
        lock_acquire(&tableLock);
        list_push_back(&frame_table, &frame->elem);
        lock_release(&tableLock);
        return frame;
    }

    pad = palloc_get_page(PAL_USER);
    if (pad == NULL)
    {
        bool evictAble = frameEvict();

        if (evictAble)
            pad = palloc_get_page(PAL_USER);
        else
        {
            free(frame);
            return NULL;
        }
    }

    initFrame(frame, pg_round_down(vad), pg_round_down(pad), curThread);

    lock_acquire(&tableLock);
    list_push_back(&frame_table, &frame->elem);
    lock_release(&tableLock);

    return frame;
}

void clearFrame(struct thread *page_dir, void *vad, void *pad)
{
    pagedir_clear_page(page_dir->pagedir, vad);
    palloc_free_page(pad);
}

bool frameEvict()
{
    struct list_elem *element = list_begin(&frame_table);
    struct frame_entry *victimFr = list_entry(element, struct frame_entry, elem);

    if (victimFr == NULL)
        return false;

    struct thread *victimTh = victimFr->frameThread;
    struct thread *victimPt = &victimTh->page_table;

    struct page_entry *victim_page = checkTable(victimPt, victimFr->vas);
    if (victim_page == NULL)
        return false;

    victim_page->pad = NULL;
    victim_page->swapI = swapOut(victimFr->pas);

    if (currentLRU != &victimFr->elem)
        list_remove(&victimFr->elem);
    else
    {
        currentLRU = list_remove(&victimFr->elem);
        if (currentLRU == list_end(&frame_table))
            currentLRU = list_begin(&frame_table);
    }

    clearFrame(victimTh, victimFr->vas, victimFr->pas);

    free(victimFr);
    return true;
}