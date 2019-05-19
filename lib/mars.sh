#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${MARSBRANCH}
fi

if [ ! -d "${MARSTMP}" ]; then
  git clone ${MARSURL} ${MARSTMP}
  ( cd ${MARSTMP} && git checkout ${MARSBRANCH} )
  cp -r ${MARSTMP}/kernel/ ${KERNELTMP}/block/mars
  ln -s ${KERNELTMP}/block/mars ${KERNELTMP}/block/mars/kernel

  ( cd ${KERNELTMP} && cat ${DISTBUILDDIR}/tmp/mars-${MARSBRANCH}/pre-patches/vanilla-${DISTKERNELMAJOR}.${DISTKERNELMINOR}/* | patch -p1 )
fi
