#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${LIBZTMP} ${LIBZTMP}-build
fi

mkdir -p ${LIBZTMP}-build

download_and_verify ${LIBZURL}/zlib-${LIBZVERSION}.tar.gz ${LIBZTMP}.tar.gz

if [ ! -d "${LIBZTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xzf ${LIBZTMP}.tar.gz )
  mv ${DISTBUILDDIR}/tmp/zlib-${LIBZVERSION} ${LIBZTMP}
fi

( cd ${LIBZTMP}-build && \
CC="${DISTTARGET}-gcc" \
CPP="${DISTTARGET}-gcc -E" \
AR="${DISTTARGET}-ar" \
RANLIB="${DISTTARGET}-ranlib" 
CFLAGS="-O2" \
LDFLAGS="" \
${LIBZTMP}/./configure --prefix=${FAKEROOTDIR}/usr
)

( cd ${LIBZTMP}-build && make ${GCCPARALLEL} && make install )