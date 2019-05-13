#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

IMAGEBUILDDIR=${IMAGEBUILDTMP}-build
IMAGECREATEPARTITION=1

rm -rf ${IMAGEBUILDDIR}
cp -r ${FAKEROOTDIR} ${IMAGEBUILDDIR}

# delete useless files
rm -rfv ${IMAGEBUILDDIR}/cross-tools
rm -rfv ${IMAGEBUILDDIR}/usr/src/*

# delete static libs
#FILES="$(ls ${IMAGEBUILDDIR}/usr/lib64/*.a)"
#for file in $FILES; do
#  rm -f $file
#done

# strip debug symbols
find ${IMAGEBUILDDIR}/{,usr/}{bin,lib,sbin} -type f -exec strip --strip-debug '{}' ';'
find ${IMAGEBUILDDIR}/{,usr/}lib64 -type f -exec strip --strip-debug '{}' ';'

# create devices + fix root fs permissions
chown -R root:root ${IMAGEBUILDDIR}
chgrp 13 ${IMAGEBUILDDIR}/var/run/utmp ${IMAGEBUILDDIR}/var/log/lastlog
mknod -m 0666 ${IMAGEBUILDDIR}/dev/null c 1 3
mknod -m 0600 ${IMAGEBUILDDIR}/dev/console c 5 1
chmod 4755 ${IMAGEBUILDDIR}/bin/busybox

# create filesystem tar
if [ ! -f "${IMAGEBUILDTMP}.tar.xz" ]; then
  (cd ${IMAGEBUILDDIR}/ && tar cJf "${IMAGEBUILDTMP}.tar.xz" *)
fi

# create + zero fill image
dd if=/dev/zero of=${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img count=${IMAGESIZE} bs=1M

# create loopback device
LODEV=`losetup --show -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img`
LOPART=${LODEV}

if [ "${IMAGECREATEPARTITION}" == "1" ]; then
  # create partition table
  (
  echo o # Create a new empty DOS partition table
  echo w # Write changes
  ) | fdisk ${LODEV} || echo
  #partprobe
  kpartx -uv ${LODEV}

  # recreate loop dev to force kernel to rescan partition table
  losetup -d ${LODEV}
  sleep 1
  LODEV=`losetup --show -P -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img`

  # create partition
  (
  echo n # Add a new partition
  echo p # Primary partition
  echo 1 # Partition number
  echo   # First sector (Accept default: 1)
  echo   # Last sector (Accept default: varies)table
  echo w # Write changes
  ) | fdisk ${LODEV}
  #partprobe
  kpartx -uv ${LODEV}

  # recreate loop dev to force kernel to rescan partition table
  losetup -d ${LODEV}
  sleep 1
  LODEV=`losetup --show -P -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img`
  LOPART=${LODEV}p1
fi

# create filesystem
mkfs.ext4 ${LOPART}
mkdir -p ${DISTBUILDDIR}/mnt
mount ${LOPART} ${DISTBUILDDIR}/mnt

# copy ${DISTNAME} filesystem to image
(cd ${DISTBUILDDIR}/mnt && tar xJf ${IMAGEBUILDTMP}.tar.xz )

# install grub bootloader
grub-install --modules=part_msdos -v --boot-directory=${DISTBUILDDIR}/mnt/boot ${LODEV}

# unmount and destroy loop dev
umount ${DISTBUILDDIR}/mnt
losetup -d ${LODEV}