#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

LOOPPARTDEV=`mount | grep ${DISTFAKEROOT} | awk '{print $1}'`
LOOPPARTNAME=`echo "${LOOPPARTDEV}" | awk -F'/' '{print $4}'`
LOOPDEV=`echo "${LOOPPARTNAME}" | sed -e 's/p1$//g'`

if [ "${LOOPDEV}" != "" ]; then
  umount ${DISTFAKEROOT} || echo -n
  dmsetup remove ${LOOPPARTNAME} || echo -n
  losetup -d /dev/${LOOPDEV} || echo -n
fi

