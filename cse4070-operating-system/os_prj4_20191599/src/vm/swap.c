#include <stdio.h>
#include <stdlib.h>
#include <bitmap.h>

#include "threads/palloc.h"
#include "threads/thread.h"
#include "threads/vaddr.h"

#include "devices/block.h"

#include "vm/page.h"
#include "vm/frame.h"
#include "vm/swap.h"

int NOT_ON_SWAP_SPACE2 = -1;

const int SECTOR = PGSIZE / BLOCK_SECTOR_SIZE;

struct block *swapBlock;
struct bitmap *swapBitmap;

void swapInit()
{
    swapBlock = block_get_role(BLOCK_SWAP);

    if (swapBlock == NULL)
        return;

    int blockCnt = block_size(swapBlock) / SECTOR;

    swapBitmap = bitmap_create(blockCnt);

    if (swapBitmap != NULL)
        bitmap_set_all(swapBitmap, false);

    return;
}

int32_t swapOut(void *pad)
{
    int blockCnt = block_size(swapBlock) / SECTOR;
    int swapI = NOT_ON_SWAP_SPACE2;

    int iter = 0;
    while (iter < blockCnt)
    {
        if (bitmap_test(swapBitmap, iter) == false)
        {
            swapI = iter;
            break;
        }
        iter++;
    }

    if (swapI != NOT_ON_SWAP_SPACE2)
    {
        iter = 0;
        while (iter < SECTOR)
        {
            block_write(swapBlock, swapI * SECTOR + iter, pad + iter * BLOCK_SECTOR_SIZE);
            iter++;
        }

        bitmap_set(swapBitmap, swapI, true);
    }

    return swapI;
}

void swapIn(void *vad, void *pad, int swapI)
{
    int i = 0;
    while (i < SECTOR)
    {
        block_read(swapBlock, swapI * SECTOR + i, pad + i * BLOCK_SECTOR_SIZE);
        i++;
    }

    struct hash *page_table = &(thread_current()->page_table);
    struct page_entry *page = checkTable(page_table, vad);

    bitmap_set(swapBitmap, swapI, false);

    page->swapI = NOT_ON_SWAP_SPACE2;
    page->loaded = true;

    pagedir_set_page(thread_current()->pagedir, vad, pad, page->writable);

    return;
}