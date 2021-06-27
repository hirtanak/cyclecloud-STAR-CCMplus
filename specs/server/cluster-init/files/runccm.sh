# Sample script for STAR-CCM+
# Copyright (c) 2019-2021 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
# Licensed under the MIT License.

#!/bin/bash
#PBS -j oe
#PBS -l select=4:ncpus=15
NP=60

logfile=starlog-`date +%Y%m%d_%H-%M-%S`.log
FILE=~/runccm.sh
echo "===========================================================================" >> $logfile
cat $FILE >> $logfile
echo "===========================================================================" >> $logfile

# Sample Command: /opt/CD-adapco/12.02.011/STAR-CCM+12.02.011/star/bin/starccm+ -np 30 -machinefile /home/azureuser/hosts -licpath 1999@flex.cd-adapco.com -power -podkey <removed> -server -rsh ssh ./MODEL1.sim

STARCCMPLUS_VERSION=15.02.007
PRECISION=-R8 #-R8 double precision
INSTALL_DIR=/shared/home/azureuser
INPUT=/shared/home/azureuser/test1.sim
#HOSTDIR=/shared/home/azureuser
export DISPLAY=0:0

source /etc/profile.d/starccm.sh

#export I_MPI_FABRICS=shm:ofa # for 2019, use I_MPI_FABRICS=shm:ofi
#export MPI_IB_PKEY=0x800c
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/lib
source /opt/intel/oneapi/mpi/latest/env/vars.sh
#MPI_ROOT="${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/mpi/intel/2018.1.163/linux-x86_64/rto/bin64"

export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com
#PODKEY=<removed>

# you spin up execute node and create hosts file on home directory.

# pingpong
#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile ${PBS_NODEFILE} hostname
#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile ${PBS_NODEFILE} IMB-MPI1 pingpong

# sample command line1
#${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -machinefile ${PBS_NODEFILE} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -mpiflags "-ppn 1 -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm:ofa" -rsh ssh -server ${INPUT}

# sample command line2 "use BatterySimulationModuleCellThermalAnalysis2Running3CellsInSeries_final.sim"
JAVA=Introduction.java
INPUT1=Introduction_final.sim
${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -rsh ssh -batch ${JAVA} ${INPUT1} >> $logfile

