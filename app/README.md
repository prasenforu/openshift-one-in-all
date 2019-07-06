# Deployment Instruction

### Sample App

Yelb allows users to vote on a set of alternatives (restaurants) and dynamically updates pie charts based on number of votes received. In addition to that Yelb keeps track of number of page views as well as it prints the hostname of the yelb-appserver instance serving the API request upon a vote or a page refresh. This allows an individual to demo the application solo, or involving people (e.g. an audience during a presentation) asking them to interact by pointing their browser to the application (which will increase the page count) and voting their favorite restaurant.

```
oc new-project sample-app
oc create sa yelb
oc adm policy add-scc-to-user anyuid system:serviceaccount:sample-app:yelb
oc create -f
oc expose service/yelb-ui
oc get all
```
