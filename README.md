# marsOS

marsOS is a tiny debian-based linux distribution that is mainly used for development and debugging tasks
for the mars block device kernel driver (https://github.com/schoebel/mars).

## prerequirements

the following applications are needed on the building host:

  * wget
  * (gnu-)tar
  * gcc,ld,ar
  * make
  * bash
  * git
  * bc
  * m4
  * gawk
  * bison
  * perl
  * find
  * strip
  * mknod
  * losetup
  * dd
  * mkfs.ext3
  * grub-install
  * kpartx
  * fdisk
  
by default the build system needs access to the internet to download source code.

i used a debian stretch minimal installation in a virtual machine to build the image with 
the following _minimum_ hardware settings:

  * 4 GB RAM
  * 6 cores
  * ~30GB of storage (strongly depending on image sizes)

refer to conf/dist.conf where all of these values can be configured.

## recommendations

it is strongly recommended to run these scripts within a virtual machine, setup only for the single purpose of
image building/debugging. misconfiguration and bugs can otherwise destroy the machine you are working on.

## security implications

for all ssh based actions, by default, your ${HOME}/.ssh/id_rsa key will be used and appended to authorized_keys
files in created images. if you run the test-suite (test.sh) it will additionally be copied into the test images.
please be aware of that.

if the key does not exists it will be created.

## configuration
  
before you build a new marsOS image you might want to have a look at conf/dist.conf located in this repo.
it contains all neccessary configuration for building a marsOS image. the default configuration should do
for you.

## create a new image
    
depending on the configuration, you might be asked to enter a root password during the image building process.

use the following command to build the image:
  
    ./build.sh

if there is an error during the build process you might want to cleanup remaining
loopback devices (losetup + dmsetup).

in case everything is successful a raw image is available in ${DISTBUILDDIR}. 
see run.sh as an example of how to run the image.

## run the image

this will run the image with qemu.

    ./run.sh

## test-suite prerequirements

a few more applications have to be installed to run the test-suite:

  * qemu-static-${DISTARCH}
  * bridge-utils

the test script will setup a so-called host-only network for the virtuals machines
involved in the tests. this affects the hosts you are executing the tests on. make
sure that the ip address range configured in conf/test.conf is unused on your machine.

testing is cpu/mem and io intensive. as a minimum requirement for test-vms i observed:

   * 1 GB RAM
   * 3 cores

the machine running the tests as well as the vms should also have at least

   * 100GB of storage

to contain all test images and artifacts.

## execute test-suite

the test-suite uses configuration from conf/dist.conf as well as conf/test.conf.
running the following command will start up 2 qemu vms based on the current image.

    ./test.sh

one will be configured as master, the other as slave.

the test script will prompt you to start the tests as well as
information of how to connect to the vms manually via ssh.