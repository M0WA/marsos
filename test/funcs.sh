#!/bin/bash

function set_image_ip() {
  BASEDIR=$1
  INTERFACE=$2
  IPNET=$3
  cat > ${BASEDIR}/etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${INTERFACE}
iface ${INTERFACE} inet static
  address ${IPNET}
EOF
}

export -f set_image_ip

function generic_testsetup() {
  BASEDIR=$1
  IMAGEHOSTNAME=$2
  INTERFACE=$3
  IPNET=$4

  echo "setting hostname: ${IMAGEHOSTNAME}"
  set_image_hostname ${BASEDIR} ${IMAGEHOSTNAME}

  echo "setting ip"
  set_image_ip ${BASEDIR} ${INTERFACE} ${IPNET}
}

export -f generic_testsetup

function wait_ssh() {
  SSHHOST=$1
  SSHUSER=$2
  SSHKEY=$3

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1 -o ConnectionAttempts=180 -v -i ${SSHKEY} ${SSHUSER}@${SSHHOST} exit 0
}

export -f wait_ssh