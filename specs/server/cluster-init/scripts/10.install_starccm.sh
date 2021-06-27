#!/bin/bash
# Copyright (c) 2019-2021 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

SW=starccm
echo "starting 10.install_${SW}.sh"

# disabling selinux
echo "disabling selinux"
setenforce 0 | exit 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

STARCCM_INSTALLATION=$(jetpack config STARCCM_INSTALLATION)
if [[ ${STARCCM_INSTALLATION} == False ]] || [[ ${STARCCM_INSTALLATION} == "None" ]]; then
   exit 0
fi

# adapt multi user environment
SCRIPTUSER=$(jetpack config SCRIPTUSER)
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
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/dnccluster/server

# default parameters
STARCCMPLUS_VERSION=14.04.011
REVISION=02
STARCCMPLUS_PLATFORM=linux-x86_64
declare PRECISION #r8 is double precison
# get file name
STARCCMPLUSFILENAME=$(jetpack config StarccmFileName)
# set parameters
STARCCMPLUS_VERSION=${STARCCMPLUSFILENAME:9:9}
REVISION=${STARCCMPLUSFILENAME:19:2}
STARCCMPLUS_PLATFORM=${STARCCMPLUSFILENAME:22:12}
PRECISION=${STARCCMPLUSFILENAME:35:2}
case "${PRECISION}" in
    "r8" ) PRECISION=-${PRECISION} ;;
    *    ) echo "double precision"
        PRECISION=""  ;;
esac
MPI_TYPE=$(jetpack config MPI)
MODEL=$(jetpack config MODEL)

# resource ulimit setting
CMD1=$(grep ulimit ${HOMEDIR}/.bashrc | sed -n 1p)
if [[ -z "${CMD1}" ]]; then
    (echo "ulimit -m unlimited"; echo "source /etc/profile.d/starccm.sh") >> ${HOMEDIR}/.bashrc
fi

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# install packages
CMD=$(jetpack config platform_version)
if [[ ${CMD} = "7.*.*" ]]; then
    yum install -y perl-Digest-MD5.x86_64 redhat-lsb-core vtk vtk-devel gcc gcc-gcc++
fi
if [[ ${CMD} = "8.*.*" ]]; then
    echo "skip installation"
fi

# License File Setting
LICENSE=$(jetpack config LICENSE)
PODKEY=$(jetpack config PODKEY)
#(echo "export STARCCMPLUS_VERSION=${STARCCMPLUS_VERSION}${PRECISION^}";
(echo "export CDLMD_LICENSE_FILE=${LICENSE}"; echo "export PODKEY=${PODKEY}") > /etc/profile.d/starccm.sh
chmod +x /etc/profile.d/starccm.sh
chown ${CUSER}:${CUSER} /etc/profile.d/starccm.sh

# Don't run if we've already expanded the STAR-CCM+ tarball. Download STAR-CCM+ installer into tempdir and unpack it into the apps directory
if [[ ! -f ${HOMEDIR}/STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz ]]; then
    #jetpack download "STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz" ${HOMEDIR}/STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz
    jetpack download "STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz" ${HOMEDIR}/
    echo "STAR-CCM+14.04.011_02_linux-x86_64-r8.tar.gz bfe91f519ff75712a16874e37583cc0e" > ${HOMEDIR}/starchecksum
    echo "STAR-CCM+14.04.013_01_linux-x86_64.tar.gz dedde2011e923019e4cb1cc9a7b2b2f8" >> ${HOMEDIR}/starchecksum
    chown ${CUSER}:${CUSER} ${HOMEDIR}/starchecksum
    chown ${CUSER}:${CUSER} ${HOMEDIR}/STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz
fi
set +u
chown ${CUSER}:${CUSER} ${HOMEDIR}/STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz
tar zxfp ${HOMEDIR}/STAR-CCM+${STARCCMPLUS_VERSION}_${REVISION}_${STARCCMPLUS_PLATFORM}${PRECISION}.tar.gz -C ${HOMEDIR}
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/starccm+_${STARCCMPLUS_VERSION}
set -u

source /etc/profile.d/starccm.sh
if [[ ! -f ${HOMEDIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}/star/bin/starccm+ ]]; then
    case ${STARCCMPLUS_VERSION:0:2} in
    "12" ) SCRIPT_VERSION="2.5_gnu4.8" ;;
    "14" ) SCRIPT_VERSION="2.12_gnu7.1" ;;
    esac
    # Install STAR-CCM+14.04.011_02_linux-x86_64-2.12_gnu7.1-r8.sh -i silent -DINSTALLDIR=${HOMEDIR}-DNODOC=true -DINSTALLFLEX=false
    sudo -u root ${HOMEDIR}/starccm+_${STARCCMPLUS_VERSION}/Disk1/InstData/VM/STARCCMPLUS.bin -i silent -DINSTALLDIR=${HOMEDIR} -DNODOC=true -DINSTALLFLEX=false | exit 0
fi

# download standard models
set +u
if [[ ! -f ${HOMEDIR}/${MODEL%%.gz} ]]; then
    jetpack download ${MODEL} ${HOMEDIR}/
    chown ${CUSER}:${CUSER} ${HOMEDIR}/${MODEL}
    case ${MODEL} in
    "TurboCharger-NoRun.sim.gz" )
        gunzip -f -d ${HOMEDIR}/${MODEL}
        chown ${CUSER}:${CUSER} ${HOMEDIR}/${MODEL%%.gz}
        echo "8d4dbbd82a6b468b394ca717c0abc599" > ${HOMEDIR}/modelchecksum
        chown ${CUSER}:${CUSER} ${HOMEDIR}/modelchecksum ;;
    esac
fi
set -u

# local file settings
if [[ ! -f ${HOMEDIR}/starccmrun.sh ]]; then
    cp ${CYCLECLOUD_SPEC_PATH}/files/runccm.sh ${HOMEDIR}/
    chmod a+rx ${HOMEDIR}/runccm.sh
    chown ${CUSER}:${CUSER} ${HOMEDIR}/runccm.sh
fi

# file settings
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/starccm+_${STARCCMPLUS_VERSION}${PRECISION^^}

# PBS job history enable
if [[ -e /opt/pbs ]]; then
    /opt/pbs/bin/qmgr -c 's s job_history_enable=1'
fi

#clean up
popd
rm -rf $tmpdir


echo "end of 10.install_${SW}.sh"
