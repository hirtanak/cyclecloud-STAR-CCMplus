#!/bin/bash
NODES=`cat ~/NODES`
NP=`cat ~/NP`
#PBS -j oe
#PBS -l select=${NODES}:ncpus=15

LSDYNA_DIR="/shared/home/azureuser/apps"
#MPI_ROOT="/shared/home/azureuser/apps/platform_mpi/bin"
MPI_ROOT="/opt/intel/compilers_and_libraries_2016.3.223/linux/mpi/intel64/bin"
source /opt/intel/compilers_and_libraries/linux/mpi/bin64/mpivars.sh
source /opt/intel/bin/compilervars.sh intel64
#export LD_LIBRARY_PATH="/shared/home/azureuser/apps/platform_mpi/lib/linux_amd64"
#INPUT="/shared/home/azureuser/apps/neon.refined.rev01.k"
#INPUT="00_Calc.dyn"
INPUT="01_Model.dyn"

${MPI_ROOT}/mpirun -np ${NP} -ppn 15 -genv I_MPI_DEBUG 5 ${LSDYNA_DIR}/ls-dyna_mpp_s_R9_3_0_x64_redhat54_ifort131_sse2_intelmpi-413 i=${INPUT} > ~/log01.log


