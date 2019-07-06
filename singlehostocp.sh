#!/bin/bash

# This scrip will install Openshift 3.11 in single host.
# Please provide host ip  & host PUBLIC IP in variable
# If you run docker in saperate storage, Please provide
# disk name (run lsblk command to ger 2nd disk) and
# uncomment 2 lines in STEP-2 "Docker setup".
# Set wild card DNS in DOMAIN (ex. cloudapps.tcs-ally.tk)
# Or you can use <Host PUBLIC IP>.nip.io


PUB_IP=<PUT PUBLIC IP>
PRI_IP=<PUT HOST IP>
#PRI_IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '172'`
NAME=`hostname`
DOCDISK=sdb
USER1=admin
USER2=pkar
DOMAIN=cloudapps.tcs-ally.tk

### STEP-1 Package download & install

echo "STEP-1 Package download & install .."

yum install -y git dos2unix

#git clone https://github.com/prasenforu/openshift-one-in-all.git /root/openshift-one-in-all/
#sleep 5
git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible/
sleep 8

cd /root/openshift-one-in-all/
dos2unix *
cd /root/openshift-ansible/
git checkout release-3.11
cd /root/openshift-one-in-all/

yum install -y docker wget net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion ansible kexec-tools sos psacct yum-utils
yum install -y centos-release-openshift-origin311

### STEP-2 Docker setup

echo "STEP-2 Docker setup .."

sed -i "s/OPTIONS.*/OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0\/16'/" /etc/sysconfig/docker

cp /etc/sysconfig/docker-storage-setup /etc/sysconfig/docker-storage-setup_bkp

#echo "DEVS=/dev/$DOCDISK" > /etc/sysconfig/docker-storage-setup
#echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup

docker-storage-setup

### STEP-3 Service enable & disable

echo "STEP-3 Service enable & disable .."

systemctl enable docker
systemctl start docker
systemctl status docker

systemctl disable firewalld
systemctl stop firewalld

systemctl enable NetworkManager.service
systemctl restart NetworkManager.service

### Passwordless login

echo "STEP-4 Passwordless login .."

ssh-keygen -f /root/.ssh/id_rsa -N ''

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
sudo chown root:root /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
echo 'StrictHostKeyChecking no' | sudo tee --append /etc/ssh/ssh_config
sudo service sshd restart

### Prepare ansible hostfile

echo "STEP-5 Prepare ansible hostfile .."

cp /root/openshift-one-in-all/allinonehost /root/openshift-one-in-all/allinonehost_bkp

sed -i "s/PPPPPPPP/$PUB_IP/g" /root/openshift-one-in-all/allinonehost
sed -i "s/IIIIIIII/$PRI_IP/g" /root/openshift-one-in-all/allinonehost
sed -i "s/ocpallinone/$NAME/g" /root/openshift-one-in-all/allinonehost
sed -i "s/$PUB_IP.nip.io/$DOMAIN/g" /root/openshift-one-in-all/allinonehost

### Run Openshift Prerequistics

echo "STEP-6 Run Openshift Prerequistics .."

ansible-playbook -i /root/openshift-one-in-all/allinonehost /root/openshift-ansible/playbooks/prerequisites.yml

### Start Openshift Installation

echo "STEP-7 Start Openshift Installation .."

echo "Make sure Prerequistics runs without error ... If yes then run below command .."
echo "ansible-playbook -i /root/openshift-one-in-all/allinonehost /root/openshift-ansible/playbooks/deploy_cluster.yml"

###### Enjoy use Openshift #######
