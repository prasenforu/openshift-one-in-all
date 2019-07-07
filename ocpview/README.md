# Openshift/Kubernetes cluster visualiser and visual explorer

KubeView displays what is happening inside a Kubernetes cluster, it maps out the API objects and how they are interconnected. Data is fetched real-time from the Kubernetes API. The status of some objects (Pods, ReplicaSets, Deployments) is colour coded red/green to represent their status and health

### Deployment

```
oc new-project ocp-view
oc create -f ocpview.yaml
oc expose service/ocpview
oc get all
```
