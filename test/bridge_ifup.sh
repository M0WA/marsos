#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

brctl addbr ${TESTBRIDGE}
brctl stp ${TESTBRIDGE} on
ip addr add ${TESTBRIDGEIP}/${TESTBRIDGENET} dev ${TESTBRIDGE}
ip link set ${TESTBRIDGE} up