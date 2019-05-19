#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTMASTERMNT}

echo "mount master image file"
mount_image ${TESTMASTERIMG} ${DISTIMAGEBYTES} p1 ${TESTMASTERMNT}

echo "setting generics on master image"
generic_testsetup ${TESTMASTERMNT} ${TESTMASTERHOSTNAME} enp0s3 ${TESTMASTERIP}/${TESTBRIDGENET} 1

echo "unmount master image"
umount_image ${TESTMASTERMNT}

if [ ! -f ${TESTMASTERTRXLOGIMG} ]; then
  echo "create mars transaction log image for master"
  create_image ${TESTMASTERTRXLOGIMG} ${TESTTRXIMAGESIZE}
fi

echo "format mars transaction log image for master"
format_image ${TESTMASTERTRXLOGIMG} ${TESTTRXIMAGESIZE} ext4

if [ ! -f ${TESTMASTERPVIMG} ]; then
  echo "create mars pv image for master"
  create_image ${TESTMASTERPVIMG} ${TESTPVIMAGESIZE}
else
  echo "overriding first 4MB of pv image for master"
  dd if=/dev/zero of=${TESTMASTERPVIMG} bs=4000000 count=1 conv=notrunc
fi
format_image ${TESTMASTERPVIMG} ${TESTPVIMAGESIZE}