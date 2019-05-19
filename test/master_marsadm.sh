#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

setup_test_lvm ${TESTMASTERIP} root ${DISTSSHKEY} /dev/sdb1

#ssh -i ${DISTSSHKEY} root@${TESTMASTERIP} marsadm --ip=${TESTMASTERIP} create-cluster