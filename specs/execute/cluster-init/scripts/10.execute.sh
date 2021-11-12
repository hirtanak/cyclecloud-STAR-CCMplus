#!/bin/bash
# Copyright (c) 2019-2021 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.execute.sh"


# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

# adapt multi user environment
jetpack users | head -n 1 > tmpfile
SCRIPTUSER=$(cut -d " " -f 2 tmpfile)
if [[ -z ${SCRIPTUSER}  ]]; then
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
   CUSER=${CUSER//\'/}
   CUSER=${CUSER//\`/}
   # After CycleCloud 7.9 and later
   if [[ -z $CUSER ]]; then
      CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
      CUSER=${CUSER//\`/}
      echo ${CUSER} > /shared/CUSER
   fi
else
   CUSER=${SCRIPTUSER}
   echo ${CUSER} > /shared/CUSER
fi
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/STAR-CCMplus/execute

# resource ulimit setting
CMD1=$(grep memlock /etc/security/limits.conf | head -2)
if [[ -z "${CMD1}" ]]; then
    (echo "* hard memlock unlimited"; echo "* soft memlock unlimited"; echo "* hard nofile 65535"; echo "* soft nofile 65535") >> /etc/security/limits.conf
fi

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

# install packages
CMD=$(jetpack config platform_version)
if [[ ${CMD} = 7.?.???? ]]; then
    echo "install STAR-CCM+ requored packages"
    yum install -y perl-Digest-MD5.x86_64 redhat-lsb-core vtk vtk-devel gcc gcc-gcc++ libXt
fi
if [[ ${CMD} = 8.?.???? ]]; then
    echo "skip installation"
    yum install -y libnsl
fi

## H16r or H16r_Promo
if [[ ${CORES} = 16 ]] ; then
    echo "Proccesing H16r"
    grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
fi

## HC/HB set up
if [[ ${CORES} = 44 ]] ; then
    echo "Proccesing HC44rs"
    grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
fi

if [[ ${CORES} = 60 ]] ; then
    echo "Proccesing HB60rs"
    grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
fi

if [[ ${CORES} = 120 ]] ; then
    echo "Proccesing HB120rs_v2"
    grep "vm.zone_reclaim_mode = 1" /etc/sysctl.conf || echo "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf sysctl -p
fi

# package install
yum install -y epel-release
yum install -y htop

# License File Setting
LICENSE=$(jetpack config LICENSE)
PODKEY=$(jetpack config PODKEY)
(echo "export CDLMD_LICENSE_FILE=${LICENSE}"; echo "export PODKEY=${PODKEY}") > /etc/profile.d/starccm.sh
chmod +x /etc/profile.d/starccm.sh
chown ${CUSER}:${CUSER} /etc/profile.d/starccm.sh


echo "end of 10.execute.sh"
