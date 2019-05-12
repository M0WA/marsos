#!/bin/bash

# based on: 
#   https://www.linuxjournal.com/content/diy-build-custom-minimal-linux-distribution-source
#   https://www.linuxjournal.com/content/build-custom-minimal-linux-distribution-source-part-ii

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/dist.conf
source ${SCRIPTPATH}/lib/funcs.sh

echo "cleanup old builds"
rm -rf ${DISTBUILDDIR}
mkdir -p ${DISTBUILDDIR}/tmp

echo "initialize filesystem hierarchy"
${SCRIPTPATH}/lib/fs.sh

echo "configure inittab"
${SCRIPTPATH}/lib/init.sh

echo "configure fakeroot"
${SCRIPTPATH}/lib/fakeroot.sh

echo "preparing vanilla kernel sources"
${SCRIPTPATH}/lib/kernel_sources.sh

echo "preparing mars fs"
${SCRIPTPATH}/lib/mars.sh

echo "copy kernel headers including mars"
${SCRIPTPATH}/lib/kernel_headers.sh

echo "build + install binutils"
${SCRIPTPATH}/lib/binutils.sh

echo "build static gcc for compile tool chain"
${SCRIPTPATH}/lib/gcc_static.sh

echo "build glibc for compile tool chain"
${SCRIPTPATH}/lib/glibc.sh

echo "build gcc cross compiler"
${SCRIPTPATH}/lib/gcc_cross.sh

echo "build busybox"
${SCRIPTPATH}/lib/busybox.sh

echo "build kernel"
${SCRIPTPATH}/lib/kernel_build.sh

echo "depmod"
${SCRIPTPATH}/lib/busybox_depmod.sh

echo "create image from fakeroot"
${SCRIPTPATH}/lib/fakeroot_image.sh
