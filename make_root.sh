#!/bin/bash
rm -Rf mnt
mkdir mnt
cd mnt
mkdir -p bin etc dev lib proc sbin sys tmp usr usr/bin \
usr/lib usr/sbin
cd ..
cp busybox-1.21.1/busybox mnt/bin
#curl -L http://riscv.org/install-guides/linux-inittab > inittab
cat > inittab <<EOF
::sysinit:/bin/busybox mount -t proc proc /proc
::sysinit:/bin/busybox mount -t tmpfs tmpfs /tmp
::sysinit:/bin/busybox mount -o remount,rw /dev/htifbd0 /
::sysinit:/bin/busybox --install -s
/dev/ttyHTIF0::sysinit:-/bin/ash 
EOF
cp inittab mnt/etc/inittab
ln -s ../bin/busybox mnt/sbin/init
genext2fs -d mnt -b 65536 -N 1024 -q root.bin
