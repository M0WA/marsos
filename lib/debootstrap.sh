#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${DEBOOTSTRAPTMP}
fi

DEBARCH=${DISTARCH}
if [ "${DISTARCH}" == "x86_64" ]; then
    DEBARCH=amd64
fi

DEBOOTSTRAPOPS=
if [ "${DISTARCH}" != "${DISTTARGET}" ]; then
    DEBOOTSTRAPOPS=--foreign
fi

if [ "${DISTPACKAGES}" != "" ]; then
    DEBOOTSTRAPOPS="${DEBOOTSTRAPOPS} --include=${DISTPACKAGES}"
fi

if [ ! -d ${DEBOOTSTRAPTMP} ]; then
  debootstrap ${DEBOOTSTRAPOPS} --arch ${DEBARCH} ${DEBIANRELEASE} ${DEBOOTSTRAPTMP} ${DEBIANMIRROR}
fi


#if [ "${DISTARCH}" != "${DISTTARGET}" ]; then
  #TODO: second stage with qemu-static-${DISTARCH}
#fi

cp -rP ${DEBOOTSTRAPTMP}/* ${DISTFAKEROOT}/