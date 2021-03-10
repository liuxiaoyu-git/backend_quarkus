#!/bin/sh
oc project ci-cd
oc delete all --all
oc delete pvc --all 
oc delete sa jenkins
oc delete configmaps jenkins-trusted-ca-bundle
oc delete secrets nexus-credential
oc delete secrets nexus-registry
oc delete secrets postgresql
for i in $(oc get secrets | grep jenkins)
do
   oc delete secrets $i
done
oc delete rolebindings jenkins_edit
