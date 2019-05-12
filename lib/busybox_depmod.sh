#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

${FAKEROOTDIR}/cross-tools/bin/depmod.pl -F ${FAKEROOTDIR}/boot/System.map-${DISTKERNELVERSION} -b ${FAKEROOTDIR}/lib/modules/${DISTKERNELVANILLA}