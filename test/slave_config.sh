#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTSLAVEMNT}

echo "mount slave image file"
mount_image ${TESTSLAVEIMG} ${DISTIMAGEBYTES} p1 ${TESTSLAVEMNT}

echo "setting generics on slave image"
generic_testsetup ${TESTSLAVEMNT} ${TESTSLAVEHOSTNAME} enp0s3 ${TESTSLAVEIP}/${TESTBRIDGENET} 2

echo "unmount slave image"
umount_image ${TESTSLAVEMNT}

if [ ! -f ${TESTSLAVEPVIMG} ]; then
  echo "create mars pv image for slave"
  create_image ${TESTSLAVEPVIMG} ${TESTPVIMAGESIZE}
else
  echo "overriding first 4MB of pv image for slave"
  dd if=/dev/zero of=${TESTSLAVEPVIMG} bs=4000000 count=1 conv=notrunc
fi
format_image ${TESTSLAVEPVIMG} ${TESTPVIMAGESIZE}