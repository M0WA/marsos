#!/bin/bash

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/dist.conf

qemu-system-${DISTARCH} -hda ${DISTBUILDDIR}/${DISTNAME}-${DISTVERSION}.img -m 256 -curses