#!/bin/bash

set -e

function download_and_verify() {
  local URL=$1
  local LOCALFILE=$2

  if [ "${FORCEREBUILD}" == "1" ]; then
    rm -rf "${LOCALFILE}" "${LOCALFILE}.sig"
  fi

  if [ ! -f "${LOCALFILE}" ]; then
    wget -4 -nv -O "${LOCALFILE}" ${URL}
  fi

  if [ ! -f "${LOCALFILE}.sig" ]; then
    wget -4 -nv -O "${LOCALFILE}.sig" ${URL}.sig || echo
  fi

  #TODO: check gpg signature
  #      see https://www.gnupg.org/faq/gnupg-faq.html#how_do_i_verify_signed_packages
}

export -f download_and_verify

function exec_script() {
  local BASEPATH=$1
  local SCRIPTNAME=$2
  local LOGFILE=$3

  ${BASEPATH}/${SCRIPTNAME} 2>&1 | tee -a ${LOGFILE}
  local SCRIPTRC=$?
  if [ "${SCRIPTRC}" != "0" ]; then
    echo "${BASEPATH}/${SCRIPTNAME} failed with rc: $?" | tee -a ${LOGFILE}
    exit ${SCRIPTRC}
  fi
}

export -f exec_script

function mount_image() {
  local IMAGEPATH=$1
  local IMAGEBYTES=$2
  local PARTITION=$3
  local MOUNTPATH=$4

  local LODEV=`losetup --sizelimit ${IMAGEBYTES} --direct-io=on -L --show -f ${IMAGEPATH}`
  local LODEVNAME=`echo "${LODEV}" | awk -F'/' '{print $3}'`
  local LOMAPDEV=/dev/mapper/${LODEVNAME}
  local LOPART=${LOMAPDEV}${PARTITION}

  sleep 1
  kpartx -uv ${LODEV}
  sleep 1

  mkdir -p ${MOUNTPATH}
  mount ${LOPART} ${MOUNTPATH}
}

export -f mount_image

function umount_image() {
  local MOUNTPATH=$1

  local LOOPPARTDEV=`mount | grep ${MOUNTPATH} | awk '{print $1}'`
  local LOOPPARTNAME=`echo "${LOOPPARTDEV}" | awk -F'/' '{print $4}'`
  local LOOPDEV=`echo "${LOOPPARTNAME}" | sed -e 's/p1$//g'`

  if [ "${LOOPDEV}" != "" ]; then
    umount ${MOUNTPATH} || echo -n
    dmsetup remove ${LOOPPARTNAME} || echo -n
    losetup -d /dev/${LOOPDEV} || echo -n
  fi
}

export -f umount_image

function create_image() {
  local IMAGENAME=$1
  local IMAGESIZE=$2
  local IMAGEDDOPTS=$3
  local IMAGEBYTES=$( expr 1048576 '*' "${IMAGESIZE}" )

  dd if=/dev/zero of=${IMAGENAME} count=${IMAGESIZE} bs=1M ${IMAGEDDOPTS}
}

export -f create_image

function format_image() {
  local IMAGENAME=$1
  local IMAGESIZE=$2
  local IMAGEFS=$3
  local IMAGEBYTES=$( expr 1048576 '*' "${IMAGESIZE}" )

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

  if [ "${IMAGEFS}" != "" ]; then
    # create filesystem
    LOPART=${LOMAPDEV}p1
    mkfs.${IMAGEFS} ${LOPART}
    kpartx -uv ${LODEV}
    sleep 3
  fi

  dmsetup remove ${LODEVNAME}p1 || echo -n
  losetup -d ${LODEV} || echo -n
}

export -f format_image

function run_qemu() {
  local QEMUBIN=$1
  local IMAGENAME=$2
  local MEMORYSIZE=$3
  local DISPLAYTYPE=$4
  local QEMUOPTS=$5

  ${QEMUBIN} -hda ${IMAGENAME} -m ${MEMORYSIZE} -display ${DISPLAYTYPE} ${QEMUOPTS}
}

export -f run_qemu

function set_image_hostname() {
  local BASEDIR=$1
  local HOSTNAME=$2

  echo ${HOSTNAME} > ${BASEDIR}/etc/hostname
  cat > ${BASEDIR}/etc/hosts << EOF
127.0.0.1 localhost
127.0.1.1 ${HOSTNAME}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF
}
export -f set_image_hostname