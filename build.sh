#!/bin/bash

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/lib/funcs.sh

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  echo "cleanup old builds"
  rm -rf ${DISTBUILDDIR}
fi

mkdir -p ${DISTBUILDDIR}/{,mnt,tmp}

# truncate log
echo -n > ${DISTBUILDLOG}

echo "create image file"
create_image ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${DISTIMAGESIZE} ${DISTIMAGEDDOPTS} | tee -a ${DISTBUILDLOG}

echo "format image file"
format_image ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${DISTIMAGESIZE} ext3 | tee -a ${DISTBUILDLOG}

echo "mount image file"
mount_image ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img ${DISTIMAGEBYTES} p1 ${DISTFAKEROOT} | tee -a ${DISTBUILDLOG}

echo "debootstrap"
exec_script ${SCRIPTPATH} lib/debootstrap.sh ${DISTBUILDLOG}

echo "preparing vanilla kernel sources"
exec_script ${SCRIPTPATH} lib/kernel_sources.sh ${DISTBUILDLOG}

echo "preparing mars kernel module"
exec_script ${SCRIPTPATH} lib/mars.sh ${DISTBUILDLOG}

echo "build + install kernel"
exec_script ${SCRIPTPATH} lib/kernel_build.sh ${DISTBUILDLOG}

echo "config files"
exec_script ${SCRIPTPATH} lib/config_files.sh ${DISTBUILDLOG}

echo "configure sshd"
exec_script ${SCRIPTPATH} lib/sshd.sh ${DISTBUILDLOG}

echo "copy mars userspace tools"
exec_script ${SCRIPTPATH} lib/mars_user.sh ${DISTBUILDLOG}

echo "install grub"
exec_script ${SCRIPTPATH} lib/grub.sh ${DISTBUILDLOG}

echo "unmount image"
umount_image ${DISTFAKEROOT} | tee -a ${DISTBUILDLOG}