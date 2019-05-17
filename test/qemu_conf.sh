#!/bin/bash

set -e

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p /etc/qemu
cat > /etc/qemu/bridge.conf << EOF
allow ${TESTBRIDGE}
EOF