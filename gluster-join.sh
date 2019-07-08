#!/bin/bash

# This scrip will use gluster from master.
# Provide MASTER & GLUSTER host ip & name in variable
# And Please provide gluster disk name 
# (run lsblk command to ger gluster disk) 

GLUSTER_IP=<PUT GLUSTER HOST IP>
GLUSNODE=<PUT GLUSTER HOSTNAME>
GLUSDISK=sdb
MASTER_IP=<PUT MASTER HOST IP>
MASNODE=<PUT MASTER HOSTNAME>


### STEP-1 Gluster repo copy & install heketi

echo "STEP-1 Gluster repo copy & install heketi.."

cp /root/openshift-one-in-all/open311-gluster.repo /etc/yum.repos.d/open-gluster.repo
yum clean all
yum repolist
yum install -y epel-release
yum -y --enablerepo=centos-openshift-origin-gluster install heketi heketi-client

### STEP-2 Backup & edit heketi.json config file 

echo "STEP-2 Backup & edit heketi.json config file "

cp /etc/heketi/heketi.json /etc/heketi/heketi.json_ori
rm -f /etc/heketi/heketi.json
cp /root/openshift-one-in-all/storage/heketi.json /etc/heketi/heketi.json

### STEP-3 Configure Firewall access & starting heketi

echo "STEP-3 Setting Firewall access & starting heketi"

cp /root/openshift-one-in-all/storage/heketi.xml /etc/firewalld/services/heketi.xml
restorecon /etc/firewalld/services/heketi.xml
chmod 640 /etc/firewalld/services/heketi.xml

## Add Heketi service into internal firewalld zone
firewall-cmd --zone=internal --add-service=heketi --permanent

## Add an access to that zone for every node in the Gluster server
firewall-cmd --zone=internal --add-source=$GLUSTER_IP/32 --permanent

## Reload firewalld
firewall-cmd --reload

## Start heketi
systemctl enable heketi
systemctl start heketi
systemctl status heketi

### STEP-4 Create & deploy GlusterFS Cluster topology

echo "STEP-4 Creating & deploying GlusterFS Cluster topology"

cp /root/openshift-one-in-all/storage/topology-ocp.json /root/openshift-one-in-all/storage/topology-ocp.json_bkp

sed -i "s/ocpgluster1/$GLUSNODE/" /root/openshift-one-in-all/storage/topology-ocp.json
sed -i "s/10.138.0.6/$GLUSTER_IP/" /root/openshift-one-in-all/storage/topology-ocp.json
sed -i "s/DISK/$GLUSDISK/" /root/openshift-one-in-all/storage/topology-ocp.json

HEKETI_CLI_KEY="/etc/heketi/heketi_key";heketi-cli topology load --json=/root/openshift-one-in-all/storage/topology-ocp.json --server http://MASTER_IP:8080 --user admin --secret $HEKETI_CLI_KEY

### STEP-5 Create a StorageClass

echo "STEP-5 Creating a StorageClass"
 
cp /root/openshift-one-in-all/storage/storage-class-gluster.yml /root/openshift-one-in-all/storage/storage-class-gluster.yml_bkp
sed -i "s/ocpmaster1/$MASNODE/" /root/openshift-one-in-all/storage/storage-class-gluster.yml
oc create -f /root/openshift-one-in-all/storage/storage-class-gluster.yml -n default

### STEP-6 Enable gluster metric in promethus

echo "STEP-6 Enabling gluster metric in promethus"

cp /root/openshift-one-in-all/storage/gluster-metric.yml /root/openshift-one-in-all/storage/gluster-metric.yml_bkp
sed -i "s/10.138.0.3/$MASTER_IP/" /root/openshift-one-in-all/storage/gluster-metric.yml
oc create -f /root/openshift-one-in-all/storage/gluster-metric.yml -n openshift-monitoring
