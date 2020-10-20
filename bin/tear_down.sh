#!/bin/sh
for i in ci-cd dev stage uat prod
do
   oc delete all --all -n $i
   oc delete pvc --all -n $i
   oc delete project $i
done
