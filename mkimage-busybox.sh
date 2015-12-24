#!/usr/bin/env bash
# Generate a very minimal filesystem based on busybox-static,
# and load it into the local docker under the name "busybox".

echo >&2
echo >&2 'warning: this script is deprecated - see mkimage.sh and mkimage/busybox-static'
echo >&2

BUSYBOX=$1
LIBS=arm-linux-gnueabihf
#LIBS=x86_64-linux-gnu
#BUSYBOX=$(which busybox)
[ "$BUSYBOX" ] || {
    echo "Sorry, I could not locate busybox."
    echo "Try 'apt-get install busybox-static'?"
    exit 1
}

set -e
ROOTFS=${TMPDIR:-/var/tmp}/rootfs-busybox-$$-$RANDOM
mkdir $ROOTFS
cd $ROOTFS

mkdir bin etc dev dev/pts lib proc sys tmp
touch etc/resolv.conf
#cp /etc/nsswitch.conf etc/nsswitch.conf
echo root:x:0:0:root:/:/bin/sh > etc/passwd
echo root:x:0: > etc/group
ln -s lib lib64
ln -s bin sbin
cp $BUSYBOX bin
for X in $(busybox --list)
do
    ln -s busybox bin/$X
done
rm bin/init
ln bin/busybox bin/init
cp /lib/${LIBS}/lib{pthread,c,dl,nsl,nss_*}.so.* lib
cp /lib/${LIBS}/ld-* lib
for X in console null ptmx random stdin stdout stderr tty urandom zero
do
    cp -a /dev/$X dev
done

tar --numeric-owner -C $ROOTFS -cf rootfs.tar .
  
#tar --numeric-owner -cf- . | docker import - busybox

#docker run -i -u root busybox /bin/echo Success.

