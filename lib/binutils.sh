#!/bin/bash

set -e

rm -rf ${BINUTILSTMP}

download_and_verify ${BINUTILSURL}/binutils-${BINUTILSVERSION}.tar.xz ${BINUTILSTMP}.tar.xz 

( cd ${DISTBUILDDIR}/tmp && tar xJf ${BINUTILSTMP}.tar.xz )
( cd ${BINUTILSTMP} && ./configure --prefix=${FAKEROOTDIR}/cross-tools --target=${DISTTARGET} --with-sysroot=${FAKEROOTDIR} --disable-nls --enable-shared --disable-multilib )
( cd ${BINUTILSTMP} && make configure-host && make ${GCCPARALLEL} )
( cd ${BINUTILSTMP} && ln -sv lib ${FAKEROOTDIR}/cross-tools/lib64 && make install )

# TODO: why?
( cd ${BINUTILSTMP} && cp -v ${BINUTILSTMP}/include/libiberty.h ${FAKEROOTDIR}/usr/include )