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

### Add pem key content to prasen.pem file & change prmission

```
chmod 400 prasen.pem
chmod 755 *.sh
```

