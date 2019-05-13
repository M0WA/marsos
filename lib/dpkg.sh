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
( cd ${DPKGTMP}-build && \
CC="${DISTTARGET}-gcc" \
AR="${DISTTARGET}-ar" \
RANLIB="${DISTTARGET}-ranlib" CFLAGS="-O2" \
LDFLAGS="-L${FAKEROOTDIR}"
${DPKGTMP}/./configure \
--prefix=${FAKEROOTDIR}/usr \
--host=${DISTTARGET} \
--enable-mmap \
--enable-dselect \
--with-libz=${FAKEROOTDIR} \
--with-sysroot=${FAKEROOTDIR} \
--disable-nls \
--disable-shared )

( cd ${DPKGTMP}-build && make ${GCCPARALLEL} && make install )