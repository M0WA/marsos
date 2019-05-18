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

echo "create mars transaction log image for master"
create_mars_trxlog_image ${TESTMASTERTRXLOGIMG} ${TESTTRXIMAGESIZE}