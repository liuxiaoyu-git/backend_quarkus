#!/bin/sh
CICD_PROJECT=ci-cd
oc apply -f ../manifests/backend-build-pipeline.yaml -n ${CICD_PROJECT}
oc apply -f ../manifests/backend-release-pipeline.yaml -n ${CICD_PROJECT}
oc apply -f ../manifests/backend-release-uat-pipeline.yaml -n ${CICD_PROJECT}
oc apply -f ../manifests/backend-release-prod-pipeline.yaml -n ${CICD_PROJECT}
