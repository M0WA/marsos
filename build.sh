#!/bin/bash

# based on: 
#   https://www.linuxjournal.com/content/diy-build-custom-minimal-linux-distribution-source
#   https://www.linuxjournal.com/content/build-custom-minimal-linux-distribution-source-part-ii

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/dist.conf
source ${SCRIPTPATH}/lib/funcs.sh

if [ "${FORCEREBUILD}" == "1"  ]; then
  echo "cleanup old builds"
  rm -rf ${DISTBUILDDIR}
fi
mkdir -p ${DISTBUILDDIR}/tmp

# truncate log
echo -n > ${DISTBUILDLOG}

echo "initialize filesystem hierarchy"
${SCRIPTPATH}/lib/fs.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "configure inittab"
${SCRIPTPATH}/lib/init.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "configure fakeroot"
${SCRIPTPATH}/lib/fakeroot.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "preparing vanilla kernel sources"
${SCRIPTPATH}/lib/kernel_sources.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "preparing mars fs"
${SCRIPTPATH}/lib/mars.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "copy kernel headers including mars"
${SCRIPTPATH}/lib/kernel_headers.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build + install binutils"
${SCRIPTPATH}/lib/binutils.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build static gcc for compile tool chain"
${SCRIPTPATH}/lib/gcc_static.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build glibc for compile tool chain"
${SCRIPTPATH}/lib/glibc.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build gcc cross compiler"
${SCRIPTPATH}/lib/gcc_cross.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build busybox"
${SCRIPTPATH}/lib/busybox.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build kernel"
${SCRIPTPATH}/lib/kernel_build.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "depmod"
${SCRIPTPATH}/lib/busybox_depmod.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "libz"
${SCRIPTPATH}/lib/libz.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "dpkg"
${SCRIPTPATH}/lib/dpkg.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "create image from fakeroot"
${SCRIPTPATH}/lib/fakeroot_image.sh 2>&1 | tee -a ${DISTBUILDLOG}