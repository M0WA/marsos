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

echo "create mars transaction log image for slave"
create_mars_trxlog_image ${TESTSLAVETRXLOGIMG} ${TESTTRXIMAGESIZE}