#!/bin/bash

set -e

rm -rfv ${FAKEROOTDIR}/cross-tools
rm -rfv ${FAKEROOTDIR}/usr/src/*

#FILES="$(ls ${FAKEROOTDIR}/usr/lib64/*.a)"
#for file in $FILES; do
#  rm -f $file
#done

find ${FAKEROOTDIR}/{,usr/}{bin,lib,sbin} -type f -exec strip --strip-debug '{}' ';'
find ${FAKEROOTDIR}/{,usr/}lib64 -type f -exec strip --strip-debug '{}' ';'

chown -R root:root ${FAKEROOTDIR}
chgrp 13 ${FAKEROOTDIR}/var/run/utmp ${FAKEROOTDIR}/var/log/lastlog
mknod -m 0666 ${FAKEROOTDIR}/dev/null c 1 3
mknod -m 0600 ${FAKEROOTDIR}/dev/console c 5 1
chmod 4755 ${FAKEROOTDIR}/bin/busybox

(cd ${FAKEROOTDIR}/ && tar cfJ ${DISTBUILDDIR}/marsos-${DISTVERSION}.tar.xz *)
dd if=/dev/zero of=${DISTBUILDDIR}/marsos-${DISTVERSION}.img count=${IMAGESIZE} bs=1M

LODEV=`losetup --show -f ${DISTBUILDDIR}/marsos-${DISTVERSION}.img`

(
echo o # Create a new empty DOS partition table
echo w # Write changes
) | fdisk ${LODEV} || echo

losetup -d ${LODEV}
LODEV=`losetup --show -P -f ${DISTBUILDDIR}/marsos-${DISTVERSION}.img`

(
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)table
echo w # Write changes
) | fdisk ${LODEV}
partprobe

mkfs.ext4 ${LODEV}p1
mkdir -p ${DISTBUILDDIR}/mnt
mount ${LODEV}p1 ${DISTBUILDDIR}/mnt

(cd ${DISTBUILDDIR}/mnt && tar xJf ${DISTBUILDDIR}/marsos-${DISTVERSION}.tar.xz )
grub-install --root-directory=${DISTBUILDDIR}/mnt ${LODEV}

umount ${DISTBUILDDIR}/mnt

losetup -d ${LODEV}