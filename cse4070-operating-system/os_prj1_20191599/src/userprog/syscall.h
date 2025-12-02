#ifndef USERPROG_SYSCALL_H
#define USERPROG_SYSCALL_H

typedef int pid_t;

void syscall_init(void);
void checkAddr(const void *vaddr);
void mySysHalt();
void mySysExit(int status);
pid_t mySysExec(const char *file);
int mySysWait(pid_t pid);
int mySysRead(int fd, void *buf, unsigned size);
int mySysWrite(int fd, const void *buf, unsigned size);
int mySysFib (int n);
int mySysMax(int a, int b, int c, int d);

#endif /* userprog/syscall.h */
