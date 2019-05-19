#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

setup_test_lvm ${TESTSLAVEIP} root ${DISTSSHKEY} /dev/sdc1
#ssh -i ${DISTSSHKEY} root@${TESTSLAVEIP} marsadm join-cluster ${TESTMASTERIP}