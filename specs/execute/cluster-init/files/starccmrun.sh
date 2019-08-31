#!/bin/bash
#PBS -j oe
#PBS -l nodes=2:ppn=16

LSDYNA_DIR="/shared/home/azureuser/apps"
MPI_ROOT="/shared/home/azureuser/apps/platform_mpi/bin"
INPUT="/shared/home/azureuser/apps/neon.refined.rev01.k"

cd ${PBS_O_WORKDIR}
NP=$(wc -l ${PBS_NODEFILE} | awk '{print $1}')
${MPI_ROOT}/mpirun -np ${NP} ${LSDYNA_DIR}/ls-dyna_mpp_s_R9_3_0_x64_redhat54_ifort131_sse2_platformmpi info 


#${MPI_ROOT}/mpirun -np ${NP} ${ADVC_BIN} < ${INPUT}
#${ADVC_DIR}/ADVCSolver ${INPUT} -out-dir ~/ -np ${NP} | tee ADVC-`date +%Y%m%d_%H-%M-%S`.log
