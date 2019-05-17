#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/dist.conf

if [ "${FORCEREBUILD}" == "1"  ]; then
  echo "cleanup old builds"
  rm -rf ${DISTBUILDDIR}
fi

mkdir -p ${DISTBUILDDIR}/{,mnt,tmp}

# truncate log
echo -n > ${DISTBUILDLOG}

echo "create + mount image"
${SCRIPTPATH}/lib/image_file.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "debootstrap"
${SCRIPTPATH}/lib/debootstrap.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "preparing vanilla kernel sources"
${SCRIPTPATH}/lib/kernel_sources.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "preparing mars fs"
${SCRIPTPATH}/lib/mars.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "build + install kernel"
${SCRIPTPATH}/lib/kernel_build.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "config files"
${SCRIPTPATH}/lib/config_files.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "copy mars userspace tools"
${SCRIPTPATH}/lib/mars_user.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "install grub"
${SCRIPTPATH}/lib/grub.sh 2>&1 | tee -a ${DISTBUILDLOG}

echo "unmount image"
#${SCRIPTPATH}/lib/image_umount.sh 2>&1 | tee -a ${DISTBUILDLOG}