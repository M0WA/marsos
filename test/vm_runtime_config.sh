#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

VMNUMBER=0
VMIP=${TESTVMSTARTIP}

while [ ${VMNUMBER} -lt ${TESTVMCOUNT} ]; do

  IMAGEIP=${TESTBRIDGEIPNET}.${VMIP}
  setup_test_lvm ${IMAGEIP} root ${DISTSSHKEY} /dev/sdb1

  VMNUMBER=$[$VMNUMBER+1]
  VMIP=$[$VMIP+1]

done