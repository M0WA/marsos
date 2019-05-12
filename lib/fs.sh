#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${FAKEROOTDIR}
fi

###############################################################################
# filesystem hierarchy

mkdir -pv ${FAKEROOTDIR}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -pv ${FAKEROOTDIR}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv ${FAKEROOTDIR}/var/{lock,log,mail,run,spool}
mkdir -pv ${FAKEROOTDIR}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${FAKEROOTDIR}/root
install -dv -m 1777 ${FAKEROOTDIR}{/var,}/tmp
install -dv ${FAKEROOTDIR}/etc/init.d
mkdir -pv ${FAKEROOTDIR}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv ${FAKEROOTDIR}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${FAKEROOTDIR}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${FAKEROOTDIR}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
for dir in ${FAKEROOTDIR}/usr{,/local}; do
     ln -sv share/{man,doc,info} ${dir}
done

###############################################################################
# initialize log files

touch ${FAKEROOTDIR}/var/run/utmp ${FAKEROOTDIR}/var/log/{btmp,lastlog,wtmp}
chmod -v 664 ${FAKEROOTDIR}/var/run/utmp ${FAKEROOTDIR}/var/log/lastlog

###############################################################################
# cross-compilation tools

install -dv ${FAKEROOTDIR}/cross-tools{,/bin}

###############################################################################
# mtab

ln -svf ../proc/mounts ${FAKEROOTDIR}/etc/mtab