#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  ( cd ${KERNELTMP} && make mrproper )
fi

( cd ${KERNELTMP} && make ARCH=${DISTARCH} headers_check && make ARCH=${DISTARCH} INSTALL_HDR_PATH=dest headers_install )
cp -rv ${KERNELTMP}/dest/include/* ${FAKEROOTDIR}/usr/include