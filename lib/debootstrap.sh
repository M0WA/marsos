#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

DEBOOTSTRAPOPS=
if [ "${DISTARCH}" != "${DISTTARGET}" ]; then
    DEBOOTSTRAPOPS=--foreign
fi

DEBARCH=${DISTARCH}
if [ "${DISTARCH}" == "x86_64" ]; then
    DEBARCH=amd64
fi

debootstrap ${DEBOOTSTRAPOPS} --arch ${DEBARCH} ${DEBIANRELEASE} ${DISTFAKEROOT} ${DEBIANMIRROR}