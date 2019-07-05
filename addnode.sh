#!/bin/bash

# This scrip will add NEWNODE in ocp singlehost cluster.
# Please provide host ip  & host PUBLIC IP in variable
# If you run docker in saperate storage, Please provide
# disk name (run lsblk command to ger 2nd disk) and
# uncomment 2 lines in STEP-3 "Docker setup".

PRI_IP=10.138.0.17
#PRI_IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '172'`
NEWNODE=<PUT NEW HOSTNAME>
DOCDISK=sdb

### Passwordless login

echo "STEP-1 Passwordless login .."

scp -i prasen.pem /root/.ssh/id_rsa.pub centos@$NEWNODE:/home/centos/.ssh/id_rsa.pub_root
ssh centos@$NEWNODE -i prasen.pem "sudo mv /home/centos/.ssh/id_rsa.pub_root /root/.ssh/authorized_keys"
ssh centos@$NEWNODE -i prasen.pem "sudo chown root:root /root/.ssh/authorized_keys"
ssh centos@$NEWNODE -i prasen.pem "sudo chmod 600 /root/.ssh/authorized_keys"
ssh centos@$NEWNODE -i prasen.pem "sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config"
ssh centos@$NEWNODE -i prasen.pem "sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config"
ssh centos@$NEWNODE -i prasen.pem "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
ssh centos@$NEWNODE -i prasen.pem "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config"
ssh centos@$NEWNODE -i prasen.pem "sudo service sshd restart"

### STEP-2 Package download & install

echo "STEP-2 Package download & install .."

ssh $NEWNODE "yum install -y wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion ansible kexec-tools sos psacct yum-utils"
ssh $NEWNODE "yum install -y centos-release-openshift-origin311"


### STEP-3 Docker setup & enable-disable services

echo "STEP-3 Docker setup & enable-disable services .."

touch /root/openshift-one-in-all/docker-storage-setup
#echo "DEVS=/dev/$DOCDISK" > /root/openshift-one-in-all/docker-storage-setup
#echo "VG=docker-vg" >> /root/openshift-one-in-all/docker-storage-setup

ssh $NEWNODE "cp /etc/sysconfig/docker-storage-setup /etc/sysconfig/docker-storage-setup_bkp"
ssh $NEWNODE "sed -i \"/^OPTIONS=/ s:.*:OPTIONS=\'--selinux-enabled --insecure-registry 172.30.0.0\/16\':\" /etc/sysconfig/docker"
scp /root/openshift-one-in-all/docker-storage-setup $NEWNODE:/etc/sysconfig/docker-storage-setup
ssh $NEWNODE "docker-storage-setup"

ssh $NEWNODE "systemctl enable docker"
ssh $NEWNODE "systemctl start docker"
ssh $NEWNODE "systemctl status docker"
ssh $NEWNODE "systemctl enable NetworkManager.service"
ssh $NEWNODE "systemctl restart NetworkManager.service"
ssh $NEWNODE "systemctl status NetworkManager.service"
ssh $NEWNODE "systemctl disable firewalld"
ssh $NEWNODE "systemctl stop firewalld"

### Prepare ansible hostfile

echo "STEP-4 Prepare ansible hostfile .."

cp /root/openshift-one-in-all/allinonehost /root/openshift-one-in-all/allinonehost_singlehost

sed -i "s/NNNNNNNNN/$PRI_IP/g" /root/openshift-one-in-all/allinonehost
sed -i "s/ocpcluster2node1/$NEWNODE/g" /root/openshift-one-in-all/allinonehost
sed -i "s/#//g" /root/openshift-one-in-all/allinonehost

### Start new node adding

echo "STEP-5 Start new node adding .."

#ansible-playbook -i /root/openshift-one-in-all/allinonehost /root/openshift-ansible/playbooks/openshift-node/scaleup.yml

### RUN Post installation step

#echo "STEP-8 Running Post installation steps .."

#Edit NEWNODE labels & remove master and infra labels

#oc edit node $NEWNODE
