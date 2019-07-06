#!/bin/bash

# This scrip will need to run post install Openshift.
# Please provide USER1  & USER2 in variable

USER1=admin
USER2=pkar

### RUN Post installation step

echo "STEP-8 Running Post installation steps .."

cp /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.original
htpasswd -b -c /etc/origin/master/htpasswd $USER1 $USER12675
htpasswd -b /etc/origin/master/htpasswd $USER2 $USER22675

#### Providing admin rights to users

oc adm policy add-cluster-role-to-user cluster-admin $USER1
oc adm policy add-cluster-role-to-user cluster-admin $USER2
oc adm policy add-scc-to-user privileged $USER1
oc adm policy add-scc-to-user privileged $USER2

###### Enjoy use Openshift #######
