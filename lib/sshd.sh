#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${DISTFAKEROOT}/root/.ssh
chmod -R u=rwx,g=,o= ${DISTFAKEROOT}/root/.ssh

if [ ! -f ${DISTSSHKEY} ]; then
  ssh-keygen -f ${DISTSSHKEY}
fi

cat ${DISTSSHKEY}.pub > ${DISTFAKEROOT}/root/.ssh/authorized_keys
chmod u=rwx,g=,o= ${DISTFAKEROOT}/root/.ssh/authorized_keys

chown -R 0:0 ${DISTFAKEROOT}/root/.ssh