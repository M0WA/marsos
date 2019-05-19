#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

echo "checkout mars test-suite"
mkdir -p ${TESTBUILDDIR}/tmp
if [ ! -d ${TESTSUITETMP} ]; then
  git clone ${TESTSUITEURL} ${TESTSUITETMP}
  ( cd ${TESTSUITETMP} && git checkout ${TESTSUITEBRANCH} )
fi

VMNUMBER=0
VMIP=${TESTVMSTARTIP}
VMIPLIST=""

while [ ${VMNUMBER} -lt ${TESTVMCOUNT} ]; do
  
  IMAGEIP=${TESTBRIDGEIPNET}.${VMIP}
  VMIPLIST="${IMAGEIP} ${VMIPLIST}"

  VMNUMBER=$[$VMNUMBER+1]
  VMIP=$[$VMIP+1]
done

echo "configure mars test-suite"
cat > ${TESTSUITETMP}/mars/mars.preconf << EOF
const_host_list="${VMIPLIST}"
EOF

echo "run mars test-suite"
( cd ${TESTSUITETMP}/mars && \
timeout=${TESTSUITETIMEOUT} \
const_net_dev=enp0s3 \
${TESTSUITETMP}/scripts/run-tests.sh )