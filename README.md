# KFS (Kernel From Scratch)

## Goals

KFS aims to replicate a crucial part of the Linux kernel that runs on x86 (32-bit) CPUs.

Our key objectives include:

 - ABI-compatible with the Linux kernel
 - Run Alpine Linux userspace
 - Support PS/2 keyboard, IDE HDD, VGA output

## Build and run

We recommend using `docker` to build KFS.

### Build

Build and run the Docker container:
```bash
$ docker buildx build -t kfs .
$ docker run --rm -it -v .:/kfs kfs bash
```

Then, inside the container:
```bash
$ make all
```

### Run

Requires QEMU.
```bash
$ make run
```

## But does it run DOOM?

Yes, certainly.

(Click the image below to watch full video)

[![Video Title](https://img.youtube.com/vi/MkH1cvJ4n3Q/0.jpg)](https://www.youtube.com/watch?v=MkH1cvJ4n3Q)

## Implemented features

- **Boot and architecture**
  - Multiboot-based x86 32-bit kernel entry written in Rust and assembly.
  - GDT/IDT setup, interrupt and exception dispatch, system call entry through `int 0x80`.
  - ACPI table discovery for MADT, FADT, and HPET information.
  - Local APIC, I/O APIC, HPET, and APIC timer initialization.

- **Memory management**
  - Paging initialization with kernel page directories, fixed mappings, and arbitrary mappings.
  - Physical page allocation, buddy-style page allocation, virtual address allocation, and cache allocators.
  - User memory management for ELF segments, user stacks, `brk`, `mmap`, `munmap`.
  - Basic out-of-memory handler.

- **Processes and scheduling**
  - Kernel threads and user tasks with PID allocation, process tree tracking, parent/child relationships, sessions, and process groups.
  - `fork`, `execve`, `exit` `waitpid`, UID/GID handling and file descriptor tables.
  - Round-Robin preemptive scheduling.
  - sleep queues, `nanosleep`, polling, and a background worker queue.
  - POSIX-style signal delivery with masks, queued signal info, default actions, signal handlers, `sigaction`, `sigreturn`, stop/continue handling, and syscall restart support.

- **Filesystems and storage**
  - VFS layer with inode, directory entry, file handle, socket handle, symlink, permission, stat, lookup, mount, and unmount abstractions.
  - Boot-time tmpfs root, followed by optional ext2 root filesystem mounting from the first detected IDE partition.
  - tmpfs, devfs, procfs, sysfs, and ext2 support.
  - `/dev` nodes for TTYs, IDE partitions, `null`, and `zero`.
  - `/proc` task directories and mount listing, plus `/sys/modules` entries for loaded kernel modules.
  - File operations including `open`, `close`, `read`, `write`, `readv/writev`, `lseek/_llseek`, `getdents/getdents64`, `link`, `unlink`, `symlink`, `readlink`, `mkdir`, `rmdir`, `rename`, `chmod`, `chown`, `truncate`, `statx`, `statfs64`, `fcntl`, `ioctl`, and `sendfile`.

- **Drivers and devices**
  - Serial console support for early boot and runtime logging.
  - VGA text/framebuffer backend and terminal/TTY layer with termios state and foreground TTY switching.
  - PS/2 keyboard input through the loadable `kbd` module.
  - PCI bus enumeration and IDE controller discovery.
  - Bus-master IDE DMA, PIO block reads, partition table parsing, asynchronous block loading, and write-back scheduling.

- **ELF loading and modules**
  - ELF parser for program headers, section headers, symbol tables, string tables, loadable segments, and interpreter lookup.
  - User ELF loading for `init`, `getty`, shell, and test programs.
  - Relocatable kernel object loading with section copying, `R_386_32`, `R_386_PC32`, and `R_386_PLT32` relocation handling.
  - Runtime kernel module load/unload syscalls with module tracking exposed through sysfs.

- **IPC and local sockets**
  - Anonymous pipes.
  - Local-domain sockets.
  - Socket syscalls for `socket`, `bind`, `connect`, `listen`, `accept`, `sendto`, and `recvfrom`.

- **Userspace**
  - Minimal C userspace runtime with syscall wrapper headers and startup code.
  - Built-in `init`, `getty`, shell, libc-style helper functions, and focused test programs for argv, files, mmap, pipes, signals, sleep, sockets, and UID/GID changes.

## Implemented syscalls

| No. | Syscall | Handler | Notes |
| ---: | --- | --- | --- |
| 1 | exit | `sys_exit` |  |
| 2 | fork | `sys_fork` |  |
| 3 | read | `sys_read` |  |
| 4 | write | `sys_write` |  |
| 5 | open | `sys_open` |  |
| 6 | close | `sys_close` |  |
| 7 | waitpid | `sys_waitpid` |  |
| 8 | creat | `sys_creat` |  |
| 9 | link | `sys_link` |  |
| 10 | unlink | `sys_unlink` |  |
| 11 | execve | `sys_execve` |  |
| 12 | chdir | `sys_chdir` |  |
| 15 | chmod | `sys_chmod` |  |
| 19 | lseek | `sys_lseek` |  |
| 20 | getpid | `sys_getpid` |  |
| 21 | mount | `sys_mount` |  |
| 22 | umount | `sys_umount` |  |
| 37 | kill | `sys_kill` |  |
| 38 | rename | `sys_rename` |  |
| 39 | mkdir | `sys_mkdir` |  |
| 40 | rmdir | `sys_rmdir` |  |
| 41 | dup | `sys_dup` |  |
| 42 | pipe | `sys_pipe` |  |
| 45 | brk | `sys_brk` |  |
| 48 | signal | `sys_signal` |  |
| 52 | umount2 | `sys_umount` | Mapped to `umount`. |
| 54 | ioctl | `sys_ioctl` |  |
| 55 | fcntl | `sys_fcntl` |  |
| 57 | setpgid | `sys_setpgid` |  |
| 63 | dup2 | `sys_dup2` |  |
| 64 | getppid | `sys_getppid` |  |
| 65 | getpgrp | `sys_getpgrp` |  |
| 66 | setsid | `sys_setsid` |  |
| 67 | sigaction | `sys_sigaction` |  |
| 80 | reboot | `sys_reboot` |  |
| 83 | symlink | `sys_symlink` |  |
| 85 | readlink | `sys_readlink` |  |
| 90 | mmap | `sys_mmap` |  |
| 91 | munmap | `sys_munmap` |  |
| 92 | truncate | `sys_truncate` |  |
| 114 | wait4 | `sys_waitpid` | Mapped to `waitpid`. |
| 119 | sigreturn | `sys_sigreturn` |  |
| 122 | uname | `sys_uname` |  |
| 128 | init_module | `sys_init_module` |  |
| 129 | delete_module | `sys_cleanup_module` |  |
| 132 | getpgid | `sys_getpgid` |  |
| 140 | _llseek | `sys_llseek` |  |
| 141 | getdents | `sys_getdents` |  |
| 145 | readv | `sys_readv` |  |
| 146 | writev | `sys_writev` |  |
| 147 | getsid | `sys_getsid` |  |
| 158 | sched_yield | `sys_sched_yield` |  |
| 162 | nanosleep | `sys_nanosleep` |  |
| 168 | poll | `sys_poll` |  |
| 174 | rt_sigaction | `sys_sigaction` | Mapped to `sigaction`. |
| 175 | rt_sigprocmask | `sys_sigprocmask` |  |
| 179 | rt_sigsuspend | `sys_sigsuspend` |  |
| 183 | getcwd | `sys_getcwd` |  |
| 190 | vfork | `sys_fork` | Mapped to `fork`. |
| 192 | mmap2 | `sys_mmap` | Mapped to `mmap`. |
| 199 | getuid32 | `sys_getuid` |  |
| 200 | getgid32 | `sys_getgid` |  |
| 212 | chown32 | `sys_chown` |  |
| 213 | setuid32 | `sys_setuid` |  |
| 214 | setgid32 | `sys_setgid` |  |
| 220 | getdents64 | `sys_getdents` |  |
| 221 | fcntl64 | `sys_fcntl` | Mapped to `fcntl`. |
| 238 | tkill | `sys_kill` | Mapped to `kill`. |
| 239 | sendfile64 | `sys_sendfile` |  |
| 243 | set_thread_area | `sys_set_thread_area` |  |
| 252 | exit_group | `sys_exit` | Mapped to `exit`. |
| 258 | set_tid_address | `sys_set_tid_address` |  |
| 265 | clock_gettime | `sys_clock_gettime` |  |
| 268 | statfs64 | `sys_statfs64` |  |
| 320 | utimensat | `sys_utimensat` |  |
| 331 | pipe2 | `sys_pipe` | Mapped to `pipe`. |
| 359 | socket | `sys_socket` |  |
| 361 | bind | `sys_bind` |  |
| 362 | connect | `sys_connect` |  |
| 363 | listen | `sys_listen` |  |
| 364 | accept4 | `sys_accept` | Accept-style handler. |
| 369 | sendto | `sys_sendto` |  |
| 371 | recvfrom | `sys_recvfrom` |  |
| 383 | statx | `sys_statx` |  |
| 10000 | draw_buffer | `sys_draw_buffer` | KFS-specific syscall. |
| 10001 | get_key_state | `sys_get_key_state` | KFS-specific syscall. |
| 10002 | deteach_tty | `sys_deteach_tty` | KFS-specific syscall. |
| 10003 | attach_tty | `sys_attach_tty` | KFS-specific syscall. |
