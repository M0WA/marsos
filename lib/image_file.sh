#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  echo "cleanup old image"
  rm -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img
fi

DDOPTS=
if [ "${DISTIMAGESPARSE}" == "1" ]; then
  DDOPTS=conv=sparse
fi

# create + zero fill image
if [ ! -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ]; then
  dd if=/dev/zero of=${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${DDOPTS} count=${DISTIMAGESIZE} bs=1M
fi

# create loopback device
LODEV=`losetup --sizelimit ${DISTIMAGEBYTES} --direct-io=on -L --show -f ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img`
LODEVNAME=`echo "${LODEV}" | awk -F'/' '{print $3}'`
LOMAPDEV=/dev/mapper/${LODEVNAME}

# create partition
(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector
echo w # Write changes
) | fdisk ${LODEV} || echo -n
kpartx -uv ${LODEV}

sleep 3
LOPART=${LOMAPDEV}p1

# create filesystem
mkfs.ext3 ${LOPART}
