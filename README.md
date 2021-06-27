#!/bin/bash
#PBS -j oe
#PBS -l select=4:ncpus=15
NP=60

logfile=starlog-`date +%Y%m%d_%H-%M-%S`.log
FILE=~/runccm.sh
echo "===========================================================================" >> $logfile
cat $FILE >> $logfile
echo "===========================================================================" >> $logfile

STARCCMPLUS_VERSION=15.02.007
PRECISION=-R8 #-R8 double precision
INSTALL_DIR=/shared/home/azureuser
INPUT=/shared/home/azureuser/test1.sim
export DISPLAY=0:0

source /etc/profile.d/starccm.sh

source /opt/intel/oneapi/mpi/latest/env/vars.sh

export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com
#PODKEY=<removed>
	
# sample command line2 "use BatterySimulationModuleCellThermalAnalysis2Running3CellsInSeries_final.sim"
JAVA=Introduction.java
INPUT1=Introduction_final.sim
${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -rsh ssh -batch ${JAVA} ${INPUT1} >> $logfile
