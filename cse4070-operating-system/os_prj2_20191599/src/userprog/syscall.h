#ifndef USERPROG_SYSCALL_H
#define USERPROG_SYSCALL_H

#include <stdio.h>
typedef int pid_t;

void syscall_init(void);
void checkAddr(const void *vaddr);
void mySysHalt();
void mySysExit(int status);
pid_t mySysExec(const char *file);
int mySysWait(pid_t pid);
int mySysRead(int fd, void *buf, unsigned size);
int mySysWrite(int fd, const void *buf, unsigned size);
int mySysFib(int n);
int mySysMax(int a, int b, int c, int d);
bool mySysCreate(const char *file, unsigned initial_size);
bool mySysRemove(const char *file);
int mySysOpen(const char *file);
void mySysClose(int fd);
int mySysFileSize(int fd);
void mySysSeek(int fd, unsigned position);
unsigned mySysTell(int fd);

#endif /* userprog/syscall.h */
