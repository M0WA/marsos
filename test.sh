#!/bin/bash

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/conf/test.conf
source ${SCRIPTPATH}/lib/funcs.sh
source ${SCRIPTPATH}/test/funcs.sh

function generic_test_config() {
  BASEDIR=$1
  HOSTNAME=$2
  IP=$3

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
export -f generic_test_config

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

# truncate log
echo -n > ${TESTLOG}

echo "configure qemu bridge permissions"
exec_script ${SCRIPTPATH} test/qemu_conf.sh ${TESTLOG}

echo "copying images"
exec_script ${SCRIPTPATH} test/test_images.sh ${TESTLOG}

echo "config master image"
exec_script ${SCRIPTPATH} test/config_master.sh ${TESTLOG}

echo "config slave image"
exec_script ${SCRIPTPATH} test/config_slave.sh ${TESTLOG}

echo "create bridge"
exec_script ${SCRIPTPATH} test/bridge_ifup.sh ${TESTLOG}

echo "starting mars master"
run_qemu qemu-system-${DISTARCH} ${TESTMASTERIMG} 256 none "-daemonize -net nic -net bridge,br=${TESTBRIDGE}"

echo "waiting for mars master"
wait_ssh ${TESTMASTERIP} root ${DISTSSHKEY}

echo "starting mars slave"
run_qemu qemu-system-${DISTARCH} ${TESTSLAVEIMG}  256 none "-daemonize -net nic -net bridge,br=${TESTBRIDGE}"

echo "waiting for mars slave"
wait_ssh ${TESTSLAVEIP} root ${DISTSSHKEY}

echo "run tests (press enter to continue)"
#TODO: actually run tests
read

echo "shutdown vms"
#TODO: we could do better here
killall qemu-system-${DISTARCH}
sleep 3

echo "destroy bridge"
exec_script ${SCRIPTPATH} test/bridge_ifdown.sh ${TESTLOG}