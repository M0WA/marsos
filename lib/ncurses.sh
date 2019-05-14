#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${NCURSESTMP} ${NCURSESTMP}-build
fi

mkdir -p ${NCURSESTMP}-build

download_and_verify ${NCURSESURL}/ncurses-${NCURSESVERSION}.tar.gz ${NCURSESTMP}.tar.gz

if [ ! -d "${NCURSESTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xzf ${NCURSESTMP}.tar.gz )
fi

( cd ${NCURSESTMP}-build && \
CC="${DISTTARGET}-gcc" \
CPP="${DISTTARGET}-gcc -E" \
AR="${DISTTARGET}-ar" \
RANLIB="${DISTTARGET}-ranlib" 
CFLAGS="-O2" \
LDFLAGS="-L${FAKEROOTDIR}" \
${NCURSESTMP}/./configure \
--with-install-prefix=${FAKEROOTDIR} \
--target=${DISTTARGET} \
--with-build-cc=${DISTTARGET}-gcc \
--with-build-cpp="${DISTTARGET}-gcc -E" \
--with-build-ldflags="-L${FAKEROOTDIR}" \
 )

( cd ${NCURSESTMP}-build && make ${GCCPARALLEL} && make install )