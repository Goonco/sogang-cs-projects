#ifndef VM_PAGE_H
#define VM_PAGE_H

#include <hash.h>

struct page_entry
{
    struct hash_elem elem;

    int swapI;
    bool writable;
    bool loaded;

    void *vad;
    void *pad;
};

unsigned pageHash(const struct hash_elem *p, void *aux);

bool pushPage(void *vaddr, void *paddr, bool writable);

struct page_entry *checkPage(const void *vaddr);
struct page_entry *checkTable(struct hash *page_table, void *vaddr);

#endif