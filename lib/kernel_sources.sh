#!/bin/bash

set -e

rm -rf ${KERNELTMP}*
download_and_verify ${DISTKERNELURL}/linux-${DISTKERNELVANILLA}.tar.xz ${KERNELTMP}.tar.xz

( cd ${DISTBUILDDIR}/tmp && tar xJf ${KERNELTMP}.tar.xz )
