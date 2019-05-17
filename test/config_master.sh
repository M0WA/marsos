#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTMASTERMNT}

echo "mount master image file"
mount_image ${TESTMASTERIMG} ${IMAGESIZEBYTES} p1 ${TESTMASTERMNT}

echo "setting generics on master image"
generic_testsetup ${TESTMASTERMNT} ${TESTMASTERHOSTNAME} enp0s3 ${TESTMASTERIP}/${TESTBRIDGENET}

echo "unmount master image"
umount_image ${TESTMASTERMNT}