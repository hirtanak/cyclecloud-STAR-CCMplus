#!/bin/bash
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 10.execute.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

#HOMEDIR=$(jetpack config cuser.home_dir)
#CUSER=${HOMEDIR##*/}
CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}

# default parameters
STARCCMPLUS_VERSION=14.04.011
REVISION=02
STARCCMPLUS_PLATFORM=linux-x86_64
PRECISION=r8 #r8 is single precison
# get file name
STARCCMPLUSFILENAME=$(jetpack config StarccmFileName)
# set parameters
STARCCMPLUS_VERSION=${STARCCMPLUSFILENAME:9:9}
REVISION=${STARCCMPLUSFILENAME:19:2}
STARCCMPLUS_PLATFORM=${STARCCMPLUSFILENAME:22:12}
PRECISION=${STARCCMPLUSFILENAME:35:2}

# resource unlimit setting
CMD1=$(tail -1 /etc/security/limits.conf)
if [[ $CMD1 != '* soft nofile 65535' ]]; then
  (echo "* hard memlock unlimited"; echo "* soft memlock unlimited"; echo "* hard nofile 65535"; echo "* soft nofile 65535") >> /etc/security/limits.conf
fi

# License File Setting
LICENSE=$(jetpack config LICENSE)
PODKEY=$(jetpack config PODKEY)
(echo "export STARCCMPLUS_VERSION=${STARCCMPLUS_VERSION}"; echo "export PRECISION=-${PRECISION^}"; echo "export CDLMD_LICENSE_FILE=${LICENSE}"; echo "export PODKEY=${PODKEY}") > /etc/profile.d/starccm.sh
chmod a+x /etc/profile.d/starccm.sh
chown ${CUSER}:${CUSER} /etc/profile.d/starccm.sh

## Checking VM SKU and Cores
VMSKU=`cat /proc/cpuinfo | grep "model name" | head -1 | awk '{print $7}'`
CORES=$(grep cpu.cores /proc/cpuinfo | wc -l)

# mandatory packages
yum install -y perl-Digest-MD5.x86_64 redhat-lsb-core vtk vtk-devel gcc gcc-gcc++

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

echo "end of 10.execute.sh"
