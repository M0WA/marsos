#!/bin/bash

set -e

( cd ${KERNELTMP} && make mrproper && make ARCH=${DISTARCH} headers_check && make ARCH=${DISTARCH} INSTALL_HDR_PATH=dest headers_install )
cp -rv ${KERNELTMP}/dest/include/* ${FAKEROOTDIR}/usr/include