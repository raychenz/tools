#!/bin/bash

set -x

cd ~
echo Download Phoronix Test Suite 7.6 stable and Install it...
wget http://phoronix-test-suite.com/releases/phoronix-test-suite-7.6.0.tar.gz
tar xzvf phoronix-test-suite-7.6.0.tar.gz
cd phoronix-test-suite
sudo ./install-sh
cd ~
echo Phoronix test suite installation completed...

echo Install php-cli, php-xml, php-zip...
sudo apt-get install php-cli php-xml php-zip
echo php-cli, php-xml and php-zip installation completed...

echo Batch install tests pts/aio-stress pts/iozone pts/sqlite pts/hdparm-read pts/ramspeed pts/stream
phoronix-test-suite batch-install pts/aio-stress pts/iozone pts/sqlite pts/hdparm-read pts/ramspeed pts/stream | tee pts_install$1.log 2>&1
phoronix-test-suite batch-setup
phoronix-test-suite batch-run pts/aio-stress pts/iozone pts/sqlite pts/hdparm-read pts/ramspeed pts/stream | tee pts$1.log
phoronix-test-suite list-saved-results | tee pts_list_results$1.log 2>&1
ls  ~/.phoronix-test-suite/test-results/ | xargs -L 1 phoronix-test-suite result-file-to-csv



echo Install sysbench...
sudo apt-get -y install sysbench

echo Running Sysbench CPU Benchmark Test and save to sysbench-all$1.log... 
echo ==================CPU Benchmark Test================ > sysbench-all$1.log
sysbench --test=cpu --cpu-max-prime=20000 run | tee -a sysbench-all$1.log 2>&1
echo ==================================================== >> sysbench-all$1.log 

echo Running Sysbench mutex Test and save to sysbench-all$1.log...
echo ==================mutex Test================ >> sysbench-all$1.log
sysbench --test=mutex --num-threads=10000 --mutex-locks=100000 run | tee -a sysbench-all$1.log 2>&1
echo ==================================================== >> sysbench-all$1.log 

echo Running Sysbench memory read Test and save to sysbench-all$1.log...
echo ==================memory read Test Test================ >> sysbench-all$1.log
sysbench --test=memory --memory-block-size=8K --memory-total-size=1G --memory-oper=read run | tee -a sysbench-all$1.log 2>&1
echo ==================================================== >> sysbench-all$1.log 

echo ==================memory write Test Test================ >> sysbench-all$1.log
echo Running Sysbench memory write Test and save to sysbench-all$1.log...
sysbench --test=memory --memory-block-size=8K --memory-total-size=1G --memory-oper=write run | tee -a sysbench-all$1.log 2>&1
echo ==================================================== >> sysbench-all$1.log 

echo ==================Fileio Test================ >> sysbench-all$1.log
echo Running Sysbench fileio Test and save to sysbench-all$1.log...
sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw prepare | tee -a sysbench-all$1.log 2>&1

sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw run | tee -a sysbench-all$1.log 2>&1

sysbench --num-threads=16 --test=fileio --file-total-size=3G --file-test-mode=rndrw cleanup | tee -a sysbench-all$1.log 2>&1
echo ==================================================== >> sysbench-all$1.log 

echo Sysbench completde, the result is sysbench-all$1.log | tee -a sysbench-all$1.log


echo Install Bonnie++.....
sudo apt-get install bonnie++

echo ==================bonnie++ Test================ >> bonnie$1.log
echo Running bonnie++ 
sudo bonnie++ -d /tmp -r 2048 -u root | tee -a bonnie$1.log 2>&1
echo ==================================================== >> bonnie$1.log
echo bonnie++ completde, the result is bonnie_patched.log | tee -a bonnie$1.log


echo Install flexible I/O tester
sudo apt-get install -y fio

echo ==================FIO /home Test================ >> fio$1.log
echo Running FIO benchmark test on /home
fio fio_home.conf | tee -a fio$1.log 2>&1
echo ==================================================== >> fio$1.log

echo ==================FIO /raid Test================ >> fio$1.log
echo Running FIO benchmark test on /raid
sudo fio fio_raid.conf | tee -a fio$1.log 2>&1
echo ==================================================== >> fio$1.log
echo FIO test completde, the result is fio$1.log | tee -a fio$1.log



