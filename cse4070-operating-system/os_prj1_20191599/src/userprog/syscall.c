#include "userprog/syscall.h"
#include <stdio.h>
#include <syscall-nr.h>
#include <string.h>
#include "threads/interrupt.h"
#include "threads/thread.h"
#include "threads/vaddr.h"

static void syscall_handler(struct intr_frame *);

void syscall_init(void)
{
  intr_register_int(0x30, 3, INTR_ON, syscall_handler, "syscall");
}

static void
syscall_handler(struct intr_frame *f)
{
  // printf("Systemcall #%d\n", *(uint32_t *)(f->esp));
  // hex_dump(f->esp, f->esp, 100, 1);

  switch (*(uint32_t *)(f->esp))
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
  case SYS_READ:
  {
    int fd = (int)*(uint32_t *)(f->esp + 4);
    void *buf = (void *)*(uint32_t *)(f->esp + 8);
    unsigned size = (unsigned)*(uint32_t *)(f->esp + 12);
    f->eax = mySysRead(fd, buf, size);
    break;
  }
  case SYS_WRITE:
  {
    int fd = (int)*(uint32_t *)(f->esp + 4);
    const void *buf = (void *)*(uint32_t *)(f->esp + 8);
    unsigned size = (unsigned)*(uint32_t *)(f->esp + 12);
    f->eax = mySysWrite(fd, buf, size);
    break;
  }
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
  // default:
  //   printf("Default Syscall Number");
  // }

  return;
}

// is_kernel_vaddr (const void *vaddr)
// {
//   return vaddr >= PHYS_BASE;
// }
void checkAddr(const void *vaddr)
{
  if (is_kernel_vaddr(vaddr))
    mySysExit(-1);
}

void mySysHalt()
{
  // syscall0 (SYS_HALT);
  shutdown_power_off();
}

void mySysExit(int status)
{
  // syscall1 (SYS_EXIT, status);
  printf("%s: exit(%d)\n", thread_name(), status);
  thread_current()->exit_status = status;
  thread_exit();
}

pid_t mySysExec(const char *file)
{
  // syscall1 (SYS_EXEC, file);
  return process_execute(file);
}

int mySysWait(pid_t pid)
{
  // syscall1 (SYS_WAIT, pid);
  return process_wait(pid);
}

int mySysRead(int fd, void *buf, unsigned size)
{
  // syscall3 (SYS_READ, fd, buffer, size);
  if (fd == 0)
  {
    int cnt = 0;
    while (cnt++ < (int)size)
    {
      uint8_t c = input_getc();
      if (c == '\0')
        break;
    }
    return cnt;
  }
  else
    return -1;
}

int mySysWrite(int fd, const void *buf, unsigned size)
{
  // syscall3 (SYS_WRITE, fd, buffer, size);
  if (fd == 1)
  {
    putbuf((char *)buf, (size_t)size);
    return size;
  }
  else
    return 0;
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
