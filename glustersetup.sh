#!/bin/bash

# This scrip will setup single node Gluster cluster.
# Please provide host ip  & host name in variable
# And Please provide gluster disk name 
# (run lsblk command to ger gluster disk) 

GLUSNODE=<PUT GLUSTER HOSTNAME>

### Passwordless login

echo "STEP-1 Passwordless login setup from master .."

scp -i prasen.pem /root/.ssh/id_rsa.pub centos@$GLUSNODE:/home/centos/.ssh/id_rsa.pub_root
ssh centos@$GLUSNODE -i prasen.pem "sudo cat /home/centos/.ssh/id_rsa.pub_root >> /root/.ssh/authorized_keys"

### STEP-2 Gluster repo copy & install

echo "STEP-2 Gluster repo copy & install .."

scp $GLUSNODE /root/openshift-one-in-all/open311-gluster.repo $GLUSNODE:/etc/yum.repos.d/open-gluster.repo

ssh $GLUSNODE "yum clean all"
ssh $GLUSNODE "yum repolist"
ssh $GLUSNODE "yum -y --enablerepo=centos-openshift-origin-gluster install glusterfs glusterfs-server"

### STEP-3 Gluster daemon start & enable service

echo "STEP-3 Gluster daemon start & enable service .."

ssh $GLUSNODE "systemctl enable glusterd"
ssh $GLUSNODE "systemctl start glusterd"
ssh $GLUSNODE "systemctl status glusterd"
ssh $GLUSNODE "systemctl disable iptables"
ssh $GLUSNODE "systemctl stop iptables"

### Setup master to use Gluster

echo "STEP-4 Setup master to use Gluster .."

echo "execute gluster-join.sh"
