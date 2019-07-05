# Openshift Setup All in One

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying OpenShift in single host.

### Clone packeges 

```
yum install -y git dos2unix
git clone https://github.com/prasenforu/openshift-one-in-all.git /root/openshift-one-in-all/
cd /root/openshift-one-in-all/
dos2unix *
```

### Single node installation

Please provide host ip  & host PUBLIC IP in variable. If you run docker in saperate storage, Please provide disk name (run ```lsblk``` command to ger 2nd disk) and uncomment 2 lines in STEP-2 "Docker setup". Set wild card DNS in DOMAIN (ex. cloudapps.tcs-ally.tk) or you can use <Host PUBLIC IP>.nip.io

Edit following variable as per requirement then run script ```singlehostocp.sh```

```
PUB_IP=<PUT PUBLIC IP>
PRI_IP=<PUT HOST IP>
DOCDISK=sdb
USER1=admin
USER2=pkar
DOMAIN=cloudapps.tcs-ally.tk
```

### Add node in cluster

Please provide host ip in variable. If you run docker in saperate storage, Please provide disk name (run ```lsblk``` command to ger 2nd disk) and uncomment 2 lines in STEP-3 "Docker setup". 

#### Add pem key content to prasen.pem file & change permission

```
chmod 400 prasen.pem
chmod 755 *.sh
```

Then edit following variable as per requirement then run script ```addnode.sh```

```
PRI_IP=<PUT NEW HOST IP>
NEWNODE=<PUT NEW HOSTNAME>
DOCDISK=sdb
```
