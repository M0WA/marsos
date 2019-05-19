#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

  SSHHOST=$1
  SSHUSER=$2
  SSHKEY=$3
  PVDEV=$4

setup_test_lvm ${TESTMASTERIP} root ${DISTSSHKEY} /dev/sdc1

#ssh -i ${DISTSSHKEY} root@${TESTMASTERIP} marsadm --ip=${TESTMASTERIP} create-cluster