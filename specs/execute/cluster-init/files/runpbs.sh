#!/bin/bash

cd ~/

PPN=15
echo ${1}> NODES
NODES=`cat ~/NODES`
NP=`expr ${1} \* ${PPN}`
echo ${NP} > NP

echo ${NODES} ${NP} ${PPN}

qsub -j oe -l select=${NODES}:ncpus=${PPN} ~/script.sh
#qsub -j oe ~/script2.sh
