#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1" ]; then
  rm -rf ${GCCTMP}  ${GCCTMP}-build
  rm -rf ${GMPTMP}  ${GMPTMP}-build
  rm -rf ${MPCTMP}  ${MPCTMP}-build
  rm -rf ${MPFRTMP} ${MPFRTMP}-build
fi
mkdir -p ${GCCTMP}-build ${GMPTMP}-build ${MPFRTMP}-build ${MPCTMP}-build

download_and_verify ${GMPURL}/gmp-${GMPVERSION}.tar.xz    ${GMPTMP}.tar.xz
download_and_verify ${MPFRURL}/mpfr-${MPFRVERSION}.tar.xz ${MPFRTMP}.tar.xz
download_and_verify ${MPCURL}/mpc-${MPCVERSION}.tar.gz    ${MPCTMP}.tar.gz
download_and_verify ${GCCURL}/gcc-${GCCVERSION}/gcc-${GCCVERSION}.tar.xz ${GCCTMP}.tar.xz

# build gmp
if [ ! -d "${GMPTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xJf ${GMPTMP}.tar.xz )
fi
( cd ${GMPTMP} && ./configure --prefix=${GMPTMP}-build && make ${GCCPARALLEL} && make install )

# build mpfr
if [ ! -d "${MPFRTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xJf ${MPFRTMP}.tar.xz )
fi
( cd ${MPFRTMP} && ./configure --prefix=${MPFRTMP}-build --with-gmp=${GMPTMP}-build && make ${GCCPARALLEL} && make install )

# build mpc
if [ ! -d "${MPCTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xzf ${MPCTMP}.tar.gz )
fi
( cd ${MPCTMP} && ./configure --prefix=${MPCTMP}-build --with-gmp=${GMPTMP}-build --with-mpfr=${MPFRTMP}-build && make ${GCCPARALLEL} && make install )

# configure + build gcc
# TODO: link libgmp,libmpfr and libmpc statically
if [ ! -d "${GCCTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xJf ${GCCTMP}.tar.xz )
fi
( cd ${GCCTMP}-build && \
AR=ar \
LDFLAGS="-Wl,-rpath,${FAKEROOTDIR}/cross-tools/lib -Wl,-rpath,${GMPTMP}-build/lib -Wl,-rpath,${MPFRTMP}-build/lib -Wl,-rpath,${MPCTMP}-build/lib" \
${GCCTMP}/./configure --prefix=${FAKEROOTDIR}/cross-tools \
--build=${BUILDHOSTTARGET} --host=${BUILDHOSTTARGET} \
--target=${DISTTARGET} \
--with-sysroot=${FAKEROOTDIR}/target --disable-nls \
--disable-shared \
--with-gmp=${GMPTMP}-build \
--with-mpc==${MPCTMP}-build \
--with-mpfr=${MPFRTMP}-build \
--without-headers --with-newlib --disable-decimal-float \
--disable-libgomp --disable-libmudflap --disable-libssp \
--disable-threads --enable-languages=c,c++ \
--disable-multilib --with-arch=${DISTCPU} )
( cd ${GCCTMP}-build && make ${GCCPARALLEL} all-gcc all-target-libgcc && make install-gcc install-target-libgcc )
( cd ${GCCTMP}-build && ln -vs libgcc.a `${DISTTARGET}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'` )