# Azure CycleCloud template for Siemens STAR-CCM+

## Prerequisites

1. Prepaire for your STAR-CCM+ bilnary.
2. Install CycleCloud CLI

## How to install

1. tar zxvf cyclecloud-STAR-CCMplus.tar.gz
1. cd cyclecloud-STAR-CCMplus
1. put your STAR-CCMplus binanry /blob directory.
1. Rewrite "Files" attribute for your binariy in "project.ini" file.
1. run "cyclecloud project upload cloud-storage(azure-storage)" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/pbs_extended_nfs_pw.txt" for register this template to your CycleCloud

## How to run Siemens STAR-CCM+

1. Create Execute Node manually
2. Check Node IP Address
3. Create hosts file for your nodes
4. qsub ~/starccmrun.sh (sample as below)

<pre><code>

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
</pre></code>

## Known Issues
~~1. This tempate support only single administrator. So you have to use same user between superuser(initial Azure CycleCloud User) and deployment user of this template~~

**-> Fixed by "Script User" you should input correct user in "Script User".**

~~. Currently AutoScale is disabled. you have to create execute node and get IP. In addtion, create hosts file for your execute node environment.~~

**-> Fxied**

# Azure CycleCloud用テンプレート:Siemens STAR-CCM+(NFS/PBSPro)

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。（図はOSS PBS Proテンプレートの場合）

![Azure CycleCloudの構築・テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/AzureCycleCloud-OSSPBSDefault.png "Azure CycleCloudの構築・テンプレート構成")

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

STAR-CCM+用のテンプレートになっています。
以下の構成、特徴を持っています。

1. OSS PBS ProジョブスケジューラをMasterノードにインストール
1. H16r, H16r_Promo, HC44rs, HB60rs, HB120s_v2を想定したテンプレート、イメージ
         - OpenLogic CentOS 7.6 HPC を利用
1. Masterノードに512GB * 2 のNFSストレージサーバを搭載
         - Executeノード（計算ノード）からNFSをマウント
1. MasterノードのIPアドレスを固定設定
         - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない

![Siemens STAR-CCM+ テンプレート構成](https://raw.githubusercontent.com/hirtanak/scripts/master/cctemplatedefaultdiagram.png "Siemens STAR-CCM+ テンプレート構成")

## Siemens STAR-CCM+ テンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールが必要です。 　~~展開されたAzure CycleCloudサーバのFQDNの設定が必要です。~~

1. テンプレート本体をダウンロード
1. 展開、ディレクトリ移動
1. STAR-CCM+バイナリを準備
1. project.ini内で利用するバイナリを設定、もしくはAzure CycleCloudに直接アップロード
1. cyclecloudコマンドラインからテンプレートインストール
   - tar zxvf cyclecloud-STAR-CCM+<version>.tar.gz
   - cd cyclecloud-STAR-CCM+<version>
   - cyclecloud project upload cloud-storage(古いバージョンだと、azure-storage)
   - cyclecloud import_template -f templates/pbs_extended_nfs_starccm.txt
   - デフォルトのバイナリを変更可能(199行目当たりのデフォルトファイル名を設定変更)
1. 削除したい場合、 cyclecloud delete_template STAR-CCM+ コマンドで削除可能

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
