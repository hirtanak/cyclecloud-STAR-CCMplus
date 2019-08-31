#!/bin/bash
#PBS -j oe
#PBS -l nodes=2:ppn=1
NP=2

# Sample Command: /opt/CD-adapco/12.02.011/STAR-CCM+12.02.011/star/bin/starccm+ -np 30 -machinefile /home/azureuser/hosts -licpath 1999@flex.cd-adapco.com -power -podkey <removed> -server -rsh ssh ./MODEL1_CCM11-DUCT.sim

source /etc/profile.d/starccm.sh

INSTALL_DIR="/shared/home/azureuser/apps"
MPI_ROOT="${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/mpi/intel/2018.1.163/linux-x86_64/rto/bin64"
INPUT=/shared/home/azureuser/test1.sim
export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com

cd ${PBS_O_WORKDIR}

# you spin up execute node and create hosts file on home directory.

# pingpong
#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile /shared/home/azureuser/hosts IMB-MPI1 pingpong

${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -machinefile ${INSTALL_DIR}/hosts -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -server run ${INPUT}
