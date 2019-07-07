# Openshift/Kubernetes cluster visualiser and visual explorer

### Deployment

```
oc new-project ocp-view
oc create -f ocpview.yaml
oc expose service/ocpview
oc get all
```
