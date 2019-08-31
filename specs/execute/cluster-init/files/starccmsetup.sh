#!/bin/sh

LSDYNA_VERSION=$(jetpack config ADVENTURECluster.version)
exprot ALDE_LICENSE_FILE=$(jetpack config LICENSE)
export PATH=$PATH:~/apps/
export MPI_HASIC_UDAPL=ofa-v2-ib0

#qsub -J 1 ~/
