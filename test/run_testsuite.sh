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

echo "configure mars test-suite"
cat > ${TESTSUITETMP}/mars/mars.preconf << EOF
const_host_list="${TESTMASTERIP} ${TESTSLAVEIP}"
EOF

echo "run mars test-suite"
( cd ${TESTSUITETMP}/mars && \
timeout=${TESTSUITETIMEOUT} \
const_net_dev=enp0s3 \
${TESTSUITETMP}/scripts/run-tests.sh )