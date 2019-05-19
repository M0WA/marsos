#!/bin/bash

set -e

function set_image_ip() {
  BASEDIR=$1
  INTERFACE=$2
  IPNET=$3
  MAC=$4
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
  hwaddress ether fe:fe:00:12:34:$MAC
EOF
}

export -f set_image_ip

function generic_testsetup() {
  BASEDIR=$1
  IMAGEHOSTNAME=$2
  INTERFACE=$3
  IPNET=$4
  MAC=$5

  echo "setting hostname: ${IMAGEHOSTNAME}"
  set_image_hostname ${BASEDIR} ${IMAGEHOSTNAME}

  echo "setting ip"
  set_image_ip ${BASEDIR} ${INTERFACE} ${IPNET} ${MAC}

  echo "creating mars directory"
  mkdir -p ${BASEDIR}/mars
  chown 0:0  ${BASEDIR}/mars
  chmod 0700 ${BASEDIR}/mars

  echo "creating mars mount"
  cat > ${BASEDIR}/etc/fstab << "EOF"
# file system    mount point   type    options                  dump  pass
rootfs           /             auto    defaults                 1     1
proc             /proc         proc    defaults                 0     0
sysfs            /sys          sysfs   defaults                 0     0
EOF

  echo "enable reachability"
  cp ${DISTSSHKEY} ${BASEDIR}/root/.ssh/id_rsa
  cp ${DISTSSHKEY}.pub ${BASEDIR}/root/.ssh/id_rsa.pub
  chmod 0600 ${BASEDIR}/root/.ssh/id_rsa*
  chown 0:0  ${BASEDIR}/root/.ssh/id_rsa*

  cat > ${BASEDIR}/etc/hosts << EOF
${TESTMASTERIP} ${TESTMASTERHOSTNAME}
${TESTSLAVEIP} ${TESTSLAVEHOSTNAME}
EOF
}

export -f generic_testsetup

function wait_ssh() {
  SSHHOST=$1
  SSHUSER=$2
  SSHKEY=$3

  RC=1
  TRYS=0

  set +e

  while [[ "$RC" != 0 && "${TRYS}" != 120 ]]
  do
    sleep 1
    TRYS=$[${TRYS}+1]
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=3 -o ConnectionAttempts=1 -v -i ${SSHKEY} ${SSHUSER}@${SSHHOST} exit 0
    RC=$?
  done

  set -e
}

export -f wait_ssh

function setup_test_lvm() {
  SSHHOST=$1
  SSHUSER=$2
  SSHKEY=$3
  PVDEV=$4

  ssh -i ${SSHKEY} ${SSHUSER}@${SSHHOST} /bin/bash << EOF
vgscan -v 
pvcreate -ff -y ${PVDEV}
vgcreate vg00 ${PVDEV}
EOF
}

export -f setup_test_lvm