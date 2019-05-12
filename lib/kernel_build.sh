#!/bin/bash

set -e

( cd ${KERNELTMP} && make mrproper && make ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- ${DISTARCH}_defconfig )
( cd ${KERNELTMP} && make ${GCCPARALLEL} ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- )
( cd ${KERNELTMP} && make ${GCCPARALLEL} ARCH=${DISTARCH} CROSS_COMPILE=${DISTTARGET}- INSTALL_MOD_PATH=${FAKEROOTDIR} modules_install )

cp -v ${KERNELTMP}/arch/x86/boot/bzImage ${FAKEROOTDIR}/boot/vmlinuz-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/System.map ${FAKEROOTDIR}/boot/System.map-${DISTKERNELVERSION}
cp -v ${KERNELTMP}/.config ${FAKEROOTDIR}/boot/config-${DISTKERNELVERSION}