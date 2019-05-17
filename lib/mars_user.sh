#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

cp ${MARSTMP}/userspace/marsadm ${DISTFAKEROOT}/usr/sbin/marsadm

mkdir ${DISTFAKEROOT}/mars
chown 0:0 ${DISTFAKEROOT}/mars