#include <stdio.h>
#include <stdlib.h>

#include "threads/thread.h"
#include "threads/vaddr.h"
#include "threads/palloc.h"

#include "vm/page.h"
#include "vm/frame.h"
#include "vm/swap.h"

int NOT_ON_SWAP_SPACE = -1;

struct page_entry *checkPage(const void *vad)
{
    struct hash *page_table = &(thread_current()->page_table);
    struct page_entry page;
    page.vad = pg_round_down(vad);
    struct hash_elem *element = hash_find(page_table, &page.elem);

    if (element != NULL)
        return hash_entry(element, struct page_entry, elem);
    else
        return NULL;
}

struct page_entry *checkTable(struct hash *pageTable, void *vaddr)
{
    struct page_entry page;
    page.vad = pg_round_down(vaddr);
    struct hash_elem *element = hash_find(pageTable, &page.elem);

    if (element != NULL)
        return hash_entry(element, struct page_entry, elem);
    else
        return NULL;
}

unsigned pageHash(const struct hash_elem *p, void *aux)
{
    return hash_int((int)hash_entry(p, struct page_entry, elem)->vad);
}

struct page_entry *pageCreation(void *vad, void *pad, bool canWrite)
{
    struct page_entry *page = (struct page_entry *)malloc(sizeof(struct page_entry));
    page->writable = canWrite;
    page->swapI = NOT_ON_SWAP_SPACE;
    page->loaded = true;

    page->vad = pg_round_down(vad);
    page->pad = pg_round_down(pad);
    return page;
}

bool pushPage(void *vad, void *pad, bool canWrite)
{
    struct page_entry *page = pageCreation(vad, pad, canWrite);
    struct hash *page_table = &(thread_current()->page_table);
    struct hash_elem *element = hash_find(page_table, &page->elem);

    if (element == NULL)
        hash_insert(page_table, &page->elem);
    else
    {
        struct page_entry *ptr = page;
        page = hash_entry(element, struct page_entry, elem);
        page->swapI = NOT_ON_SWAP_SPACE;
        free(ptr);
    }

    return true;
}