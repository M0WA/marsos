#!/bin/bash

set -e

${FAKEROOTDIR}/cross-tools/bin/depmod.pl -F ${FAKEROOTDIR}/boot/System.map-${DISTKERNELVERSION} -b ${FAKEROOTDIR}/lib/modules/${DISTKERNELVANILLA}