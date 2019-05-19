#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

VMNUMBER=0
VMIP=${TESTVMSTARTIP}

mkdir -p ${TESTBUILDDIR}
mkdir -p ${TESTBUILDMNT}

while [ ${VMNUMBER} -lt ${TESTVMCOUNT} ]; do

  IMAGEHOSTNAME=${TESTHOSTPREFIX}${VMNUMBER}
  IMAGEFILE=${TESTIMAGEPREFIX}_${IMAGEHOSTNAME}.img
  PHYIMAGEFILE=${TESTIMAGEPREFIX}_${IMAGEHOSTNAME}.pv.img
  IMAGEIP=${TESTBRIDGEIPNET}.${VMIP}

  echo "copying image file"
  if [ ! -f ${IMAGEFILE} ]; then
    cp ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${IMAGEFILE}
  fi

  echo "mount vm image file"
  mount_image ${IMAGEFILE} ${DISTIMAGEBYTES} p1 ${TESTBUILDMNT}

  echo "configuring vm image"
  generic_testsetup ${TESTBUILDMNT} ${IMAGEHOSTNAME} enp0s3 ${IMAGEIP}/${TESTBRIDGENET} ${VMNUMBER}

  echo "generating /etc/hosts"
  generate_etc_hosts ${TESTBUILDMNT} ${TESTHOSTPREFIX} ${TESTBRIDGEIPNET} ${TESTVMSTARTIP} ${TESTVMCOUNT}

  echo "unmount vm image"
  umount_image ${TESTBUILDMNT}

  if [ ! -f ${PHYIMAGEFILE} ]; then
    echo "create mars pv image"
    create_image ${PHYIMAGEFILE} ${TESTPVIMAGESIZE}
  else
    echo "overriding first 4MB of pv image"
    dd if=/dev/zero of=${PHYIMAGEFILE} bs=4000000 count=1 conv=notrunc
  fi
  format_image ${PHYIMAGEFILE} ${TESTPVIMAGESIZE}

  VMNUMBER=$[$VMNUMBER+1]
  VMIP=$[$VMIP+1]

done