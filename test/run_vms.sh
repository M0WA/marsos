#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

VMNUMBER=0
VMIP=${TESTVMSTARTIP}

while [ ${VMNUMBER} -lt ${TESTVMCOUNT} ]; do

  IMAGEHOSTNAME=${TESTHOSTPREFIX}${VMNUMBER}
  IMAGEFILE=${TESTIMAGEPREFIX}_${IMAGEHOSTNAME}.img
  PHYIMAGEFILE=${TESTIMAGEPREFIX}_${IMAGEHOSTNAME}.pv.img
  IMAGEIP=${TESTBRIDGEIPNET}.${VMIP}

  echo "starting vm"
  run_qemu qemu-system-${DISTARCH} ${IMAGEFILE} ${TESTVMRAM} none "-hdb ${PHYIMAGEFILE} -smp ${TESTVMCORES} -daemonize -net nic -net bridge,br=${TESTBRIDGE}"

  echo "waiting for vm to come up"
  wait_ssh ${IMAGEIP} root ${DISTSSHKEY}

  echo "config vm ssh host key"
  ssh-keygen -R ${IMAGEIP}
  ssh-keyscan -H ${IMAGEIP} >> ~/.ssh/known_hosts

  VMNUMBER=$[$VMNUMBER+1]
  VMIP=$[$VMIP+1]

done