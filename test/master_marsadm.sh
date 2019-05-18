#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

ssh -i ${DISTSSHKEY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${TESTMASTERIP} marsadm --ip=${TESTMASTERIP} create-cluster