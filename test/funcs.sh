#!/bin/bash

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

function create_mars_trxlog_image() {
  IMAGENAME=$1
  IMAGESIZE=$2
  IMAGEBYTES=$( expr 1048576 '*' "${IMAGESIZE}" )

  dd if=/dev/zero of=${IMAGENAME} count=${IMAGESIZE} bs=1M

  # create loopback device
  LODEV=`losetup --sizelimit ${IMAGEBYTES} --direct-io=on -L --show -f ${IMAGENAME}`
  LODEVNAME=`echo "${LODEV}" | awk -F'/' '{print $3}'`
  LOMAPDEV=/dev/mapper/${LODEVNAME}

  # create partition
  (
  echo o # Create a new empty DOS partition table
  echo n # Add a new partition
  echo p # Primary partition
  echo 1 # Partition number
  echo   # First sector (Accept default: 1)
  echo   # Last sector
  echo w # Write changes
  ) | fdisk ${LODEV} || echo -n
  kpartx -uv ${LODEV}
  sleep 3

  # create filesystem
  LOPART=${LOMAPDEV}p1
  mkfs.ext4 ${LOPART}
  kpartx -uv ${LODEV}
  sleep 3

  dmsetup remove ${LODEVNAME}p1 || echo -n
  losetup -d ${LODEV} || echo -n
}

export -f create_mars_trxlog_image

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
/dev/sdb1        /mars         ext4    defaults                 0     0
EOF

  echo "enable reachability"
  cp ${DISTSSHKEY} ${BASEDIR}/root/.ssh/id_rsa
  cp ${DISTSSHKEY}.pub ${BASEDIR}/root/.ssh/id_rsa.pub
  chmod 0600 ${BASEDIR}/root/.ssh/id_rsa*
  chown 0:0  ${BASEDIR}/root/.ssh/id_rsa*
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