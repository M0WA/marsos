#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${KERNELTMP}*
fi

download_and_verify ${DISTKERNELURL}/linux-${DISTKERNELVANILLA}.tar.xz ${KERNELTMP}.tar.xz

if [ ! -d "${KERNELTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xJf ${KERNELTMP}.tar.xz )
fi
