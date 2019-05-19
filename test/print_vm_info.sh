#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

VMNUMBER=0
VMIP=${TESTVMSTARTIP}

while [ ${VMNUMBER} -lt ${TESTVMCOUNT} ]; do
  
  IMAGEIP=${TESTBRIDGEIPNET}.${VMIP}
  IMAGEHOSTNAME=${TESTHOSTPREFIX}${VMNUMBER}

  echo "${IMAGEHOSTNAME}: ssh -i ${DISTSSHKEY} root@${IMAGEIP}"

  VMNUMBER=$[$VMNUMBER+1]
  VMIP=$[$VMIP+1]
done