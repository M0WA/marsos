#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  ( cd ${KERNELTMP} && make mrproper )
fi

if [ "${DISTARCH}" != "${DISTTARGET}" ]; then
  ( cd ${KERNELTMP} && make ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- ${DISTARCH}_defconfig )
  ( cd ${KERNELTMP} && make ${GCCPARALLEL} ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- )
  ( cd ${KERNELTMP} && make ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- INSTALL_MOD_PATH=${DISTFAKEROOT} modules_install )
else
  ( cd ${KERNELTMP} && make ${DISTARCH}_defconfig )
  ( cd ${KERNELTMP} && make ${GCCPARALLEL} )
  ( cd ${KERNELTMP} && make INSTALL_MOD_PATH=${DISTFAKEROOT} modules_install )
fi

cp -v ${KERNELTMP}/arch/${DISTARCH}/boot/bzImage ${DISTFAKEROOT}/boot/vmlinuz-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/System.map ${DISTFAKEROOT}/boot/System.map-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/.config ${DISTFAKEROOT}/boot/config-${DISTKERNELVERSION}