#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

cp ${MARSTMP}/userspace/marsadm ${FAKEROOTDIR}/usr/sbin/marsadm

cat > ${FAKEROOTDIR}/etc/rc.d/mars << "EOF"
#!/bin/sh

#!/bin/sh
case "$1" in
    start)
    /sbin/modprobe mars
    ;;
    stop)
    /sbin/modprobe -r mars
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
EOF
chmod u+x ${FAKEROOTDIR}/etc/rc.d/mars
chown 0:0 ${FAKEROOTDIR}/etc/rc.d/mars
ln -s /etc/rc.d/mars ${FAKEROOTDIR}/etc/init.d/S10mars
ln -s /etc/rc.d/mars ${FAKEROOTDIR}/etc/init.d/K10mars

mkdir ${FAKEROOTDIR}/mars
chown 0:0 ${FAKEROOTDIR}/mars