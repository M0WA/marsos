#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

LOOPPARTDEV=`mount | grep ${DISTFAKEROOT} | awk '{print $1}'`
LOOPPARTNAME=`echo "${LOOPPARTDEV}" | awk -F'/' '{print $4}'`
LOOPDEV=`echo "${LOOPPARTNAME}" | sed -e 's/p1$//g'`


mkdir -p ${DISTFAKEROOT}/boot/grub
cat > ${DISTFAKEROOT}/boot/grub/grub.cfg<< EOF

set default=0
set timeout=5

set root=(hd0,1)

menuentry "${DISTNAME} ${DISTVERSION}" {
        linux   /boot/vmlinuz-${DISTKERNELVERSION} root=/dev/sda1 rw quiet
}
EOF

# install grub bootloader
if [ "${LOOPDEV}" != "" ]; then
  grub-install --modules=part_msdos -v --boot-directory=${DISTFAKEROOT}/boot /dev/${LOOPDEV}
fi