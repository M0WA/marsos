#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

ip link set ${TESTBRIDGE} down
brctl delbr ${TESTBRIDGE}