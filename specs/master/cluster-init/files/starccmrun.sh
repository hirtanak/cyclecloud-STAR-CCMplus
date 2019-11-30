# Sample script for STAR-CCM+
# Copyright (c) 2019 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
# Licensed under the MIT License. 

#!/bin/bash
#PBS -j oe
#PBS -l select=2:ncpus=1
NP=2

# Sample Command: /opt/CD-adapco/12.02.011/STAR-CCM+12.02.011/star/bin/starccm+ -np 30 -machinefile /home/azureuser/hosts -licpath 1999@flex.cd-adapco.com -power -podkey <removed> -server -rsh ssh ./MODEL1.sim

source /etc/profile.d/starccm.sh

STARCCMPLUS_VERSION=14.04.013
PRECISION= #-R8 double precision
INSTALL_DIR=/shared/home/azureuser/apps
INPUT=/shared/home/azureuser/test1.sim
HOSTDIR=/shared/home/azureuser
export DISPLAY=0:0

export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
export MPI_IB_PKEY=0x800c
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/lib
source /opt/intel/impi/2019.5.281/intel64/bin/mpivars.sh
#MPI_ROOT="${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/mpi/intel/2018.1.163/linux-x86_64/rto/bin64"

export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com
#PODKEY=<removed>

# you spin up execute node and create hosts file on home directory.

# pingpong
#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile ${PBS_NODEFILE} hostname
#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile ${PBS_NODEFILE} IMB-MPI1 pingpong

# sample command line1
#${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -machinefile ${PBS_NODEFILE} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -mpiflags "-ppn 1 -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm:ofa" -rsh ssh -server ${INPUT}

# sample command line2 from "How to calculate parallel speed-up and efficiency on workstations and clusters"
INPUT1=/shared/home/azureuser/nomesh.sim
INPUT2=/shared/home/azureuser/flexbench.sim
#${INSTALL_DIR}/${STARCCMPLUS_VERSION}/STAR-CCM+${STARCCMPLUS_VERSION}/star/bin/starccm+ -np ${NP} -machinefile ${PBS_NODEFILE} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -mpiflags "-ppn ${PPN} -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm:ofa" -rsh ssh -batch -batch step1.java ${INPUT1} > starlog-`date +%Y%m%d_%H-%M-%S`.log

#${INSTALL_DIR}/${STARCCMPLUS_VERSION}/STAR-CCM+${STARCCMPLUS_VERSION}/star/bin/starccm+ -np ${NP} -machinefile ${PBS_NODEFILE} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -mpiflags "-ppn ${PPN} -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm:ofa" -rsh ssh -batch -batch step2.java ${INPUT2} > starlog-`date +%Y%m%d_%H-%M-%S`.log
