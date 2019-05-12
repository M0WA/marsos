#!/bin/bash

set -e

MARSTMP=${DISTBUILDDIR}/tmp/mars-${MARSBRANCH}
KERNELTMP=${DISTBUILDDIR}/tmp/linux-${DISTKERNELVANILLA}

rm -rf ${DISTBUILDDIR}/tmp/mars*
git clone ${MARSURL} ${MARSTMP}
( cd ${MARSTMP} && git checkout ${MARSBRANCH} )
cp -r ${MARSTMP}/kernel/ ${KERNELTMP}/block/mars
ln -s ${KERNELTMP}/block/mars ${KERNELTMP}/block/mars/kernel

( cd ${KERNELTMP} && cat ${DISTBUILDDIR}/tmp/mars-${MARSBRANCH}/pre-patches/vanilla-${DISTKERNELMAJOR}.${DISTKERNELMINOR}/* | patch -p1 )

# TODO: make patch path absolute/get rid of patch
patch ${KERNELTMP}/block/mars/Kconfig patches/0001-enable_mars_by_default.patch