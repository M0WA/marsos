#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1" ]; then
  rm -rf ${GCCTOOLTMP}
fi
mkdir -p ${GCCTOOLTMP}

( cd ${GCCTOOLTMP} && \
AR=ar LDFLAGS="-Wl,-rpath,${FAKEROOTDIR}/cross-tools/lib -Wl,-rpath,${GMPTMP}-build/lib -Wl,-rpath,${MPFRTMP}-build/lib -Wl,-rpath,${MPCTMP}-build/lib" \
${GCCTMP}/./configure --prefix=${FAKEROOTDIR}/cross-tools \
--build=${BUILDHOSTTARGET} --target=${DISTTARGET} \
--host=${BUILDHOSTTARGET} --with-sysroot=${FAKEROOTDIR} \
--disable-nls --enable-shared \
--enable-languages=c,c++ --enable-c99 \
--enable-long-long \
--with-gmp=${GMPTMP}-build \
--with-mpc==${MPCTMP}-build \
--with-mpfr=${MPFRTMP}-build \
--disable-multilib --with-arch=${DISTCPU} )

( cd ${GCCTOOLTMP} && make ${GCCPARALLEL} && make install )
cp -v ${FAKEROOTDIR}/cross-tools/${DISTTARGET}/lib64/libgcc_s.so.1 ${FAKEROOTDIR}/lib64