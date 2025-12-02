// #include "userprog/syscall.h"
// #include <stdio.h>
// #include <syscall-nr.h>
// #include <string.h>
// #include "threads/interrupt.h"
// #include "threads/thread.h"
// #include "threads/vaddr.h"
// #include "filesys/file.h"
// #include "filesys/filesys.h"
// #include "threads/synch.h"
#include "userprog/syscall.h"
#include <stdio.h>
#include <string.h>
#include <syscall-nr.h>
#include "threads/interrupt.h"
#include "threads/thread.h"
#include "threads/vaddr.h"
#include "devices/input.h"
#include "devices/shutdown.h"
#include "userprog/process.h"
#include "lib/kernel/console.h"
#include "filesys/filesys.h"
#include "filesys/file.h"

const int MAX_FD = 128;
static void syscall_handler(struct intr_frame *);

struct lock fileLock;

void syscall_init(void)
{
  lock_init(&fileLock);
  lock_init(&pageLock);
  intr_register_int(0x30, 3, INTR_ON, syscall_handler, "syscall");
}

static void
syscall_handler(struct intr_frame *f)
{

  int syscallNum = *(uint32_t *)(f->esp);
  if (syscallNum >= SYS_HALT && syscallNum <= SYS_WAIT)
  {
    switch (syscallNum)
    {
    case SYS_HALT:
    {
      mySysHalt();
      break;
    }
    case SYS_EXIT:
    {
      checkAddr(f->esp + 4);
      int status = *(uint32_t *)(f->esp + 4);
      mySysExit(status);
      break;
    }
    case SYS_EXEC:
    {
      checkAddr(f->esp + 4);
      const char *file = (char *)*(uint32_t *)(f->esp + 4);
      f->eax = mySysExec(file);
      break;
    }
    case SYS_WAIT:
    {
      checkAddr(f->esp + 4);
      pid_t pid = *(uint32_t *)(f->esp + 4);
      f->eax = mySysWait(pid);
      break;
    }
    }
  }
  else if (syscallNum == SYS_FIB || syscallNum == SYS_MAX)
  {
    switch (syscallNum)
    {
    case SYS_FIB:
    {
      int num = (int)*(uint32_t *)(f->esp + 4);
      f->eax = mySysFib(num);
      break;
    }
    case SYS_MAX:
    {
      int a = (int)*(uint32_t *)(f->esp + 4), b = (int)*(uint32_t *)(f->esp + 8), c = (int)*(uint32_t *)(f->esp + 12), d = (int)*(uint32_t *)(f->esp + 16);
      f->eax = mySysMax(a, b, c, d);
      break;
    }
    }
  }
  else
  {
    switch (syscallNum)
    {
    case SYS_READ:
    {
      checkAddr(f->esp + 4);
      checkAddr(f->esp + 8);
      checkAddr(f->esp + 12);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      void *buf = (void *)*(uint32_t *)(f->esp + 8);
      unsigned size = (unsigned)*(uint32_t *)(f->esp + 12);
      f->eax = mySysRead(fd, buf, size);
      break;
    }
    case SYS_WRITE:
    {
      checkAddr(f->esp + 4);
      checkAddr(f->esp + 8);
      checkAddr(f->esp + 12);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      const void *buf = (void *)*(uint32_t *)(f->esp + 8);
      unsigned size = (unsigned)*(uint32_t *)(f->esp + 12);
      f->eax = mySysWrite(fd, buf, size);
      break;
    }
    case SYS_CREATE:
    {
      checkAddr(f->esp + 4);
      checkAddr(f->esp + 8);
      const char *file = (const char *)*(uint32_t *)(f->esp + 4);
      unsigned initial_size = (unsigned)*(uint32_t *)(f->esp + 8);
      f->eax = mySysCreate(file, initial_size);
      break;
    }
    case SYS_REMOVE:
    {
      checkAddr(f->esp + 4);
      const char *file = (const char *)*(uint32_t *)(f->esp + 4);
      f->eax = mySysRemove(file);
      break;
    }
    case SYS_OPEN:
    {
      checkAddr(f->esp + 4);
      const char *file = (const char *)*(uint32_t *)(f->esp + 4);
      f->eax = mySysOpen(file);
      break;
    }
    case SYS_CLOSE:
    {
      checkAddr(f->esp + 4);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      mySysClose(fd);
      break;
    }
    case SYS_FILESIZE:
    {
      checkAddr(f->esp + 4);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      f->eax = mySysFileSize(fd);
      break;
    }
    case SYS_SEEK:
    {
      checkAddr(f->esp + 4);
      checkAddr(f->esp + 8);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      unsigned position = (unsigned)*(uint32_t *)(f->esp + 8);
      mySysSeek(fd, position);
      break;
    }
    case SYS_TELL:
    {
      checkAddr(f->esp + 4);
      int fd = (int)*(uint32_t *)(f->esp + 4);
      f->eax = mySysTell(fd);
      break;
    }
    }
  }

  return;
}

void checkAddr(const void *vaddr)
{
  if (is_kernel_vaddr(vaddr))
    mySysExit(-1);

  return checkPage(vaddr);
}

void mySysHalt()
{
  shutdown_power_off();
}

void mySysExit(int status)
{
  printf("%s: exit(%d)\n", thread_name(), status);
  thread_current()->exit_status = status;
  for (int i = 3; i < MAX_FD; i++)
  {
    if (thread_current()->fd[i] != NULL)
      mySysClose(i);
  }

  thread_exit();
}

pid_t mySysExec(const char *file)
{
  if (file == NULL)
    return -1;
  return process_execute(file);
}

int mySysWait(pid_t pid)
{
  return process_wait(pid);
}

int mySysFib(int n)
{
  int n1 = 1, n2 = 1, tmp;
  if (n == 1 || n == 2)
    return 1;

  for (int i = 2; i < n; i++)
  {
    tmp = n1 + n2;
    n1 = n2;
    n2 = tmp;
  }
  return n2;
}

int mySysMax(int a, int b, int c, int d)
{
  int max;
  if (a > b)
    max = a;
  else
    max = b;

  if (max < c)
    max = c;
  if (max < d)
    max = d;
  return max;
}

// ---------------------------------------------------- Proj#2

int mySysRead(int fd, void *buf, unsigned size)
{
  checkAddr(buf);
  lock_acquire(&fileLock);

  int retVal = -1;
  if (fd == 0)
  {
    int cnt = 0;
    while (cnt++ < (int)size)
    {
      uint8_t c = input_getc();
      if (c == '\0')
        break;
    }
    retVal = cnt;
  }
  else if (fd >= 3)
  {
    struct file *file = thread_current()->fd[fd];
    if (file == NULL)
    {
      lock_release(&fileLock);
      mySysExit(-1);
    }
    retVal = file_read(file, buf, size);
  }

  lock_release(&fileLock);
  return retVal;
}

int mySysWrite(int fd, const void *buf, unsigned size)
{
  checkAddr(buf);
  lock_acquire(&fileLock);

  int retVal = -1;
  if (fd == 1)
  {
    putbuf((char *)buf, (size_t)size);
    retVal = size;
  }
  else if (fd >= 3)
  {
    struct file *file = thread_current()->fd[fd];
    if (file == NULL)
    {
      lock_release(&fileLock);
      mySysExit(-1);
    }
    retVal = file_write(file, buf, size);
  }
  lock_release(&fileLock);
  return retVal;
}

bool mySysCreate(const char *file, unsigned initial_size)
{
  if (file == NULL)
    mySysExit(-1);
  return filesys_create(file, initial_size);
}

bool mySysRemove(const char *file)
{
  if (file == NULL)
    mySysExit(-1);
  return filesys_remove(file);
}

int mySysOpen(const char *file)
{
  if (file == NULL)
    mySysExit(-1);

  lock_acquire(&fileLock);
  struct file *fp = filesys_open(file);
  int retVal = -1;
  if (fp != NULL)
  {
    for (int i = 3; i < MAX_FD; i++)
    {
      if (thread_current()->fd[i] == NULL)
      {
        if (!strcmp(thread_current()->name, file))
          file_deny_write(fp);
        thread_current()->fd[i] = fp;

        retVal = i;
        break;
      }
    }
  }
  lock_release(&fileLock);
  return retVal;
}

void mySysClose(int fd)
{
  if (thread_current()->fd[fd] == NULL)
    mySysExit(-1);
  file_close(thread_current()->fd[fd]);
  thread_current()->fd[fd] = NULL;
}

int mySysFileSize(int fd)
{
  if (thread_current()->fd[fd] == NULL)
    mySysExit(-1);
  return file_length(thread_current()->fd[fd]);
}

void mySysSeek(int fd, unsigned position)
{
  if (thread_current()->fd[fd] == NULL)
    mySysExit(-1);
  file_seek(thread_current()->fd[fd], position);
}

unsigned mySysTell(int fd)
{
  if (thread_current()->fd[fd] == NULL)
    mySysExit(-1);
  return file_tell(thread_current()->fd[fd]);
}