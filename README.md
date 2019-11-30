# Azure CycleCloud template for Siemens STAR-CCM+

## Prerequisites

1. Prepaire for your STAR-CCM+ bilnary.
2. Install CycleCloud CLI

## How to install

1. tar zxvf cyclecloud-Particleworks.zip
1. cd cyclecloud-Particleworks
1. put your Particleworks binanry /blob directory.
1. Rewrite "Files" attribute for your binariy in "project.ini" file.
1. run "cyclecloud project upload azure-storage" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/pbs_extended_nfs_pw.txt" for register this template to your CycleCloud

## How to run Siemens STAR-CCM+

1. Create Execute Node manually
2. Check Node IP Address
3. Create hosts file for your nodes
4. qsub ~/starccmrun.sh (sample as below)

<pre><code>
#!/bin/bash
#PBS -j oe
#PBS -l select=2:ncpus=44
PPN=44
NP=88

cd ${PBS_O_WORKDIR}

source /etc/profile.d/starccm.sh

INSTALL_DIR="/shared/home/azureuser/apps"
I_MPI_ROOT=/opt/intel/impi/2018.4.274
source /opt/intel/impi/2018.4.274/intel64/bin/mpivars.sh
STARCCMPLUS_VERSION=14.04.011
PRECISION=-R8

INPUT=/shared/home/azureuser/test1.sim
export I_MPI_FABRICS=shm:ofa
export MPI_IB_PKEY=0x800c
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/lib

PODKEY=<removed>

DISPLAY=0:0

CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com

#/opt/intel/impi/2018.4.274/intel64/bin/mpirun -machinefile /shared/home/azureuser/hosts IMB-MPI1 pingpong

${INSTALL_DIR}/${STARCCMPLUS_VERSION}${PRECISION}/STAR-CCM+${STARCCMPLUS_VERSION}${PRECISION}/star/bin/starccm+ -np ${NP} -machinefile /shared/home/azureuser/hosts -licpath ${CDLMD_LICENSE_FILE} -power -podkey ${PODKEY} -mpi intel -mpiflags "-ppn 1 -env I_MPI_DEBUG 5 -env I_MPI_FABRICS shm:ofa" -batch /shared/home/azureuser/solve_SS_b787_images.java -load ${INPUT}
</pre></code>

## Known Issues
1. This tempate support only single administrator. So you have to use same user between superuser(initial Azure CycleCloud User) and deployment user of this template
2. Currently AutoScale is disabled. you have to create execute node and get IP. In addtion, create hosts file for your execute node environment.

# Azure CycleCloud用テンプレート:Siemens STAR-CCM+(NFS/PBSPro)

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。（図はOSS PBS Proテンプレートの場合）

![Azure CycleCloudの構築・テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/AzureCycleCloud-OSSPBSDefault.png "Azure CycleCloudの構築・テンプレート構成")

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

STAR-CCM+用のテンプレートになっています。
以下の構成、特徴を持っています。

1. OSS PBS ProジョブスケジューラをMasterノードにインストール
2. H16r, H16r_Promo, HC44rs, HB60rsを想定したテンプレート、イメージ
	 - OpenLogic CentOS 7.6 HPC を利用 
3. Masterノードに512GB * 2 のNFSストレージサーバを搭載
	 - Executeノード（計算ノード）からNFSをマウント
4. MasterノードのIPアドレスを固定設定
	 - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない

![Siemens STAR-CCM+ テンプレート構成](https://raw.githubusercontent.com/hirtanak/scripts/master/cctemplatedefaultdiagram.png "Siemens STAR-CCM+ テンプレート構成")

## Siemens STAR-CCM+ テンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
2. 展開、ディレクトリ移動
3. cyclecloudコマンドラインからテンプレートインストール 
   - tar zxvf cyclecloud-STAR-CCM+<version>.tar.gz
   - cd cyclecloud-STAR-CCM+<version>
   - cyclecloud project upload azure-storage
   - cyclecloud import_template -f templates/pbs_extended_nfs_starccm.txt
4. 削除したい場合、 cyclecloud delete_template STAR-CCM+ コマンドで削除可能

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
