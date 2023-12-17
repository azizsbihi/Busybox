#!/bin/bash

set -e
exec 2>/tmp/init_error.log  # Redirection des erreurs vers un fichier

BUSYBOX_VERSION=1.34.1
KERNEL_VERSION=5.15.6

mkdir -p src
cd src 
    #kernel
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/') #capturer le premier nombre de la version de kernel 
    wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
    tar -xf linux-$KERNEL_VERSION.tar.xz
    cd linux-$KERNEL_VERSION
        make defconfig #make default configuration
        make -j8 || exit  

    cd ..
     #busybox
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
    cd busybox-$BUSYBOX_VERSION
        make defconfig
        sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config #activer la configuration static 
        make CC=musl-gcc -j8 || exit
    cd ..
cd ..

cp src/linux-5.15.6/arch/x86_64/boot/bzImage ./
#initdr
mkdir initrd
cd initrd
mkdir -p bin dev proc sys
cd bin
cp ../../src/busybox-$BUSYBOX_VERSION/busybox ./
for prog in $(./busybox --list); do
    ln -s /bin/busybox ./$prog
done
cd ..
echo '#!/bin/bash' > init
echo 'mount -t sysfs sysfs /sys' >> init
echo 'mount -t proc proc /proc' >> init
echo 'mount -t devtmpfs devtmpfs /dev' >> init
echo 'sysctl -w kernel.printk="2 4 1 7" || true' >> init
echo '/bin/sh' >> init

chmod -R 777 .
find . | cpio -o -H newc > ../initrd.img
cd ..

# Vérifier en cas d'erreur (utilisation de set -e pour sortir en cas d'erreur) // console=`tty`
ln -s $console /dev/tty  # Ajout de la ligne pour lier /dev/tty