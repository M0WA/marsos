#!/bin/bash

function download_and_verify() {
  URL=$1
  LOCALFILE=$2

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
  BASEPATH=$1
  SCRIPTNAME=$2
  LOGFILE=$3

  ${BASEPATH}/${SCRIPTNAME} 2>&1 | tee -a ${LOGFILE}
  SCRIPTRC=$?
  if [ "${SCRIPTRC}" != "0" ]; then
    echo "${BASEPATH}/lib/${SCRIPTNAME} failed with rc: $?" | tee -a ${LOGFILE}
    exit ${SCRIPTRC}
  fi
}

export -f exec_script

function mount_image() {
  IMAGEPATH=$1
  IMAGEBYTES=$2
  PARTITION=$3
  MOUNTPATH=$4

  LODEV=`losetup --sizelimit ${IMAGEBYTES} --direct-io=on -L --show -f ${IMAGEPATH}`
  LODEVNAME=`echo "${LODEV}" | awk -F'/' '{print $3}'`
  LOMAPDEV=/dev/mapper/${LODEVNAME}
  LOPART=${LOMAPDEV}${PARTITION}

  sleep 1
  kpartx -uv ${LODEV}
  sleep 1

  mkdir -p ${MOUNTPATH}
  mount ${LOPART} ${MOUNTPATH}
}

export -f mount_image

function umount_image() {
  MOUNTPATH=$1

  LOOPPARTDEV=`mount | grep ${MOUNTPATH} | awk '{print $1}'`
  LOOPPARTNAME=`echo "${LOOPPARTDEV}" | awk -F'/' '{print $4}'`
  LOOPDEV=`echo "${LOOPPARTNAME}" | sed -e 's/p1$//g'`

  if [ "${LOOPDEV}" != "" ]; then
    umount ${MOUNTPATH} || echo -n
    dmsetup remove ${LOOPPARTNAME} || echo -n
    losetup -d /dev/${LOOPDEV} || echo -n
  fi
}

export -f umount_image

function run_qemu() {
  QEMUBIN=$1
  IMAGENAME=$2
  MEMORYSIZE=$3
  DISPLAYTYPE=$4
  QEMUOPTS=$5

  ${QEMUBIN} -hda ${IMAGENAME} -m ${MEMORYSIZE} -display ${DISPLAYTYPE} ${QEMUOPTS}
}

export -f run_qemu

function set_image_hostname() {
  BASEDIR=$1
  HOSTNAME=$2

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