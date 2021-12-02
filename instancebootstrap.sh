#!/bin/bash

# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

cd /home/opc

# set timezone to local timezone
timedatectl set-timezone Europe/Berlin

# add a script to use in case a block volume has been attached
cat << EOF > /home/opc/finishBlockVolumeSetup.sh
diskId="\$(sudo fdisk -l)"
diskId=\${diskId#*Disk /}
diskId=\${diskId#*Disk /}
diskId=\${diskId%%: *}
diskId="/\$diskId"
sudo mkfs -t ext4 -F \$diskId
echo "File system on block volume has been created at \$(date)."
echo -e '\n\n'
sleep 3s
sudo mkdir /blockvolume
sudo mount \$diskId /blockvolume
echo "Block volume has been mounted to /blockvolume at \$(date)."
echo -e '\n\n'
EOF
chmod a+x /home/opc/finishBlockVolumeSetup.sh

# install and start a httpd server
yum install -y httpd
systemctl start httpd
chkconfig httpd on
systemctl stop firewalld

# prepare pseudo-random HTML background color to easier distinguish the backend servers from each other
COLORS="808080000080008000008080800000800080808000"
COLOR=${COLORS:(( (( $(date +%s) / 300 % 7 )) * 6 )):6}

# create a static page, showing the time the pool instance has been created. Use the background color determined earlier
cd /home/opc 
sudo echo "<html><title>Test Page</title><body bgcolor=#${COLOR}><table width=100% height=100% border=0><tr><td width=25%>&nbsp;</td><td width=50%>&nbsp;</td><td width=25%>&nbsp;</td></tr><tr><td width=25%>&nbsp;</td><td width=50%><h1><font face=Arial color=#ffffff>This Pool Instance has been started on<br/>$(date).</font></h1></td><td width=25%>&nbsp;</td></tr><tr><td width=25%>&nbsp;</td><td width=50%>&nbsp;</td><td width=50%>&nbsp;</td></tr></table></body></html>" > ./index.html
sudo cp ./index.html /var/www/html

# get the metadata information about how long to simulate the CPU 100% utilization
CPU_100PERCENT_TIME=$(curl -L http://169.254.169.254/opc/v1/instance/metadata/cpu_100percent_time)

# get available number of CPU threads
NO_OF_THREADS=$(lscpu | grep "CPU(s):" | head -n 1 | awk '{ print $2 }')

# for every thread, start a background process that utilizes 100% of the thread, using the "yes" utility,
# wait the desired time in minutes, so we can watch the scaling out according to the autoscaling policy
# and terminate all these yes processes.
for i in $(seq $NO_OF_THREADS) 
do 
(
yes &>/dev/null &
PROCESS_ID=$!
sleep "${CPU_100PERCENT_TIME}m"
kill -9 $PROCESS_ID
) &>/dev/null &
done 
