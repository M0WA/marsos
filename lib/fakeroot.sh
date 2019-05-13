#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

###############################################################################
# /etc/passwd

cat > ${FAKEROOTDIR}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/sh
EOF

###############################################################################
# /etc/group

cat > ${FAKEROOTDIR}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
video:x:12:
utmp:x:13:
usb:x:14:
EOF

###############################################################################
# /etc/fstab

cat > ${FAKEROOTDIR}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order

rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
#devpts          /dev/pts        devpts  gid=4,mode=620  0      0
#tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF

###############################################################################
# /etc/profile

cat > ${FAKEROOTDIR}/etc/profile << "EOF"
export PATH=/bin:/usr/bin:/usr/local/bin/

if [ `id -u` -eq 0 ] ; then
        PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/
        unset HISTFILE
fi

export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
export TERM=xterm
EOF

###############################################################################
# set hostname

echo ${FAKEHOSTNAME} > ${FAKEROOTDIR}/etc/hostname

###############################################################################
# set issue

cat > ${FAKEROOTDIR}/etc/issue<< EOF
${DISTNAME} ${DISTVERSION}
Kernel \r (\m)

EOF

###############################################################################
# install grub

mkdir -p ${FAKEROOTDIR}/boot/grub
cat > ${FAKEROOTDIR}/boot/grub/grub.cfg<< EOF

set default=0
set timeout=5

set root=(hd0,1)

menuentry "${DISTNAME} ${DISTVERSION}" {
        linux   /boot/vmlinuz-${DISTKERNELVERSION} root=/dev/sda1 rw quiet
}
EOF