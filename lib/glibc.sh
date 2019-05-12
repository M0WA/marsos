#!/bin/bash

set -e

rm -rf ${GLIBCTMP} ${GLIBCTMP}-build

download_and_verify ${GLIBCURL}/glibc-${GLIBCVERSION}.tar.xz ${GLIBCTMP}.tar.xz

( cd ${DISTBUILDDIR}/tmp && tar xJf ${GLIBCTMP}.tar.xz )
#( cd ${GLIBCTMP} && \
#echo "libc_cv_forced_unwind=yes" > config.cache && \
#echo "libc_cv_c_cleanup=yes"     >> config.cache && \
#echo "libc_cv_ssp=no"            >> config.cache && \
#echo "libc_cv_ssp_strong=no"     >> config.cache )

mkdir -p ${GLIBCTMP}-build
( cd ${GLIBCTMP}-build && \
BUILD_CC="gcc" CC="${DISTTARGET}-gcc" \
AR="${DISTTARGET}-ar" \
RANLIB="${DISTTARGET}-ranlib" CFLAGS="-O2" \
LDFLAGS="-L${GMPTMP}-build/lib -L${MPFRTMP}-build/lib -L${MPCTMP}-build/lib" \
${GLIBCTMP}/./configure --prefix=/usr \
--host=${DISTTARGET} --build=${BUILDHOSTTARGET} \
--disable-profile --enable-add-ons --with-tls \
--enable-kernel=2.6.32 --with-__thread \
--with-binutils=${FAKEROOTDIR}/cross-tools/bin \
--with-headers=${FAKEROOTDIR}/usr/include \
--cache-file=config.cache )

( cd ${GLIBCTMP}-build && make ${GCCPARALLEL} && make install_root=${FAKEROOTDIR}/ install )