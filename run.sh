#!/bin/bash

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/lib/funcs.sh

IMAGENAME=${1:-${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img}

run_qemu qemu-system-${DISTARCH} ${IMAGENAME} 256 curses