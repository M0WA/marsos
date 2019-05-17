#!/bin/bash

set -e

brctl addbr ${TESTBRIDGE}
brctl stp ${TESTBRIDGE} on
ip addr add ${TESTBRIDGEIP}/${TESTBRIDGENET} dev ${TESTBRIDGE}
ip link set ${TESTBRIDGE} up