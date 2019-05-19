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
else
  ( cd ${KERNELTMP} && make ${DISTARCH}_defconfig )
fi

( cd ${KERNELTMP} && scripts/config -k \
-m XFS_FS -e XFS_QUOTA -e XFS_POSIX_ACL -e XFS_RT -d XFS_WARN -d XFS_DEBUG \
-m MARS -e MARS_CHECKS -d MARS_DEBUG --set-val MARS_DEFAULT_PORT 7777 -e MARS_SEPARATE_PORTS -e MARS_IPv4_TOS -e MARS_MEM_RETRY --set-str MARS_LOGDIR /mars \
--set-val MARS_ROLLOVER_INTERVAL 3 --set-val MARS_SCAN_INTERVAL 5 --set-val MARS_PROPAGATE_INTERVAL 5 --set-val MARS_SYNC_FLIP_INTERVAL 60 --set-val MARS_NETIO_TIMEOUT 30 -e MARS_MEM_PREALLOC -e MARS_FAST_FULLSYNC \
-e MARS_LOADAVG_LIMIT -d MARS_SHOW_CONNECTIONS --set-val MARS_MIN_SPACE_4 2 --set-val MARS_MIN_SPACE_3 2 --set-val MARS_MIN_SPACE_2 2 --set-val MARS_MIN_SPACE_1 2 --set-val MARS_MIN_SPACE_0 12 \
-e MARS_LOGROT --set-val MARS_LOGROT_AUTO 32 -d CONFIG_MARS_PREFER_SIO )

if [ "${DISTARCH}" != "${DISTTARGET}" ]; then
  ( cd ${KERNELTMP} && make ${GCCPARALLEL} ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- )
  ( cd ${KERNELTMP} && make ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- INSTALL_MOD_PATH=${DISTFAKEROOT} modules_install )
else
  ( cd ${KERNELTMP} && make ${GCCPARALLEL} )
  ( cd ${KERNELTMP} && make INSTALL_MOD_PATH=${DISTFAKEROOT} modules_install )
fi

cp -v ${KERNELTMP}/arch/${DISTARCH}/boot/bzImage ${DISTFAKEROOT}/boot/vmlinuz-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/System.map ${DISTFAKEROOT}/boot/System.map-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/.config ${DISTFAKEROOT}/boot/config-${DISTKERNELVERSION}