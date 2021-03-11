#!/bin/sh
oc project ci-cd
oc delete all --all
oc delete pvc --all 
oc delete sa jenkins
oc delete configmaps jenkins-trusted-ca-bundle
oc delete secrets nexus-credential
oc delete secrets nexus-registry
oc delete secrets nexus-svc-registry 
oc delete secrets postgresql
for i in $(oc get secrets | grep jenkins)
do
   oc delete secrets $i
done
oc delete rolebindings jenkins_edit
oc delete secrets nexus-registry -n dev
oc delete secrets nexus-svc-registry -n dev  
oc delete secrets nexus-registry -n stage
oc delete secrets nexus-svc-registry -n stage
oc delete secrets nexus-registry -n uat
oc delete secrets nexus-svc-registry -n uat
oc delete secrets nexus-registry -n prod 
oc delete secrets nexus-svc-registry -n prod 