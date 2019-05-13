#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${DPKGTMP} ${DPKGTMP}-build
fi

download_and_verify ${DPKGURL}/dpkg_${DPKGVERSION}.tar.xz ${DPKGTMP}.tar.xz

if [ ! -d "${DPKGTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xJf ${DPKGTMP}.tar.xz )
fi

mkdir -p ${DPKGTMP}-build
( cd ${DPKGTMP}-build && ${DPKGTMP}/./configure \
--prefix=${FAKEROOTDIR}/usr \
--target=${DISTTARGET} \
--host=${DISTTARGET} \
--with-sysroot=${FAKEROOTDIR} \
--enable-mmap \
--with-libz=${FAKEROOTDIR} \
--disable-nls \
--disable-dselect \
--disable-shared )

( cd ${DPKGTMP}-build && make ${GCCPARALLEL} && make install )