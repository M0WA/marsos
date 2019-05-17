#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTBUILDDIR}
if [ ! -f ${TESTMASTERIMG} ]; then
  cp ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${TESTMASTERIMG}
fi
if [ ! -f ${TESTSLAVEIMG} ]; then
  cp ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${TESTSLAVEIMG}
fi
