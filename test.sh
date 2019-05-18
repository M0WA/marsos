#!/bin/bash

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/conf/test.conf
source ${SCRIPTPATH}/lib/funcs.sh
source ${SCRIPTPATH}/test/funcs.sh

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTBUILDDIR}

# truncate log
echo -n > ${TESTLOG}

echo "configure qemu bridge permissions"
exec_script ${SCRIPTPATH} test/qemu_conf.sh ${TESTLOG}

echo "copying images"
exec_script ${SCRIPTPATH} test/test_images.sh ${TESTLOG}

echo "config master image"
exec_script ${SCRIPTPATH} test/master_config.sh ${TESTLOG}

echo "config slave image"
exec_script ${SCRIPTPATH} test/slave_config.sh ${TESTLOG}

echo "create bridge"
exec_script ${SCRIPTPATH} test/bridge_ifup.sh ${TESTLOG}

echo "starting mars master"
run_qemu qemu-system-${DISTARCH} ${TESTMASTERIMG} 256 none "-hdb ${TESTMASTERTRXLOGIMG} -daemonize -net nic -net bridge,br=${TESTBRIDGE}"

echo "starting mars slave"
run_qemu qemu-system-${DISTARCH} ${TESTSLAVEIMG}  256 none "-hdb ${TESTSLAVETRXLOGIMG} -daemonize -net nic -net bridge,br=${TESTBRIDGE}"

echo "waiting for mars master"
wait_ssh ${TESTMASTERIP} root ${DISTSSHKEY}

echo "do mars runtime configuration on master"
exec_script ${SCRIPTPATH} test/master_marsadm.sh ${TESTLOG}

echo "waiting for mars slave"
wait_ssh ${TESTSLAVEIP} root ${DISTSSHKEY}

echo "do mars runtime configuration on slave"
exec_script ${SCRIPTPATH} test/slave_marsadm.sh ${TESTLOG}

echo "run test-suite"
exec_script ${SCRIPTPATH} test/run_testsuite.sh ${TESTLOG}

echo "test finished, press enter to shutdown and cleanup"
read

echo "shutdown vms"
#TODO: we could do better here
killall qemu-system-${DISTARCH}
sleep 3

echo "destroy bridge"
exec_script ${SCRIPTPATH} test/bridge_ifdown.sh ${TESTLOG}