#!/bin/bash

set -e

function set_image_ip() {
  local BASEDIR=$1
  local INTERFACE=$2
  local IPNET=$3
  local MAC=$4

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
  local BASEDIR=$1
  local IMAGEHOSTNAME=$2
  local INTERFACE=$3
  local IPNET=$4
  local MAC=$5

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
}

export -f generic_testsetup

function generate_etc_hosts() {
  local HOSTPREFIX=$1
  local IPNET=$2
  local IPSTART=$3
  local VMCOUNT=$4

  local VMNUMBER=0
  local VMIP=${IPSTART}

  while [ ${VMNUMBER} -lt ${VMCOUNT} ]; do
  
    local IMAGEIP=${IPNET}.${VMIP}
    local IMAGEHOSTNAME=${HOSTPREFIX}${VMNUMBER}

    echo -e "\n${IMAGEIP} ${IMAGEHOSTNAME}" >> ${BASEDIR}/etc/hosts

    VMNUMBER=$[$VMNUMBER+1]
    VMIP=$[$VMIP+1]
  done
}

export -f generate_etc_hosts

function wait_ssh() {
  local SSHHOST=$1
  local SSHUSER=$2
  local SSHKEY=$3

  local RC=1
  local TRYS=0

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
  local SSHHOST=$1
  local SSHUSER=$2
  local SSHKEY=$3
  local PVDEV=$4

  ssh -i ${SSHKEY} ${SSHUSER}@${SSHHOST} /bin/bash << EOF
vgscan -v 
pvcreate -ff -y ${PVDEV}
vgcreate vg00 ${PVDEV}
EOF
}

export -f setup_test_lvm