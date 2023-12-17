#!/bin/bash

BUSYBOX_VERSION=1.34.1
KERNEL_VERSION=5.15.6

#qemu-system-x86_64 -kernel bzImage -initrd initrd.img
#qemu-system-x86_64 -kernel bzImage -initrd initrd.img 
console=`tty`
ln -s $console /dev/tty
qemu-system-x86_64 -kernel bzImage -initrd initrd.img 





