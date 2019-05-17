#!/bin/bash

set -e

ip link set ${TESTBRIDGE} down
brctl delbr ${TESTBRIDGE}