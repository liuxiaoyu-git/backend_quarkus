#!/bin/sh
CICD_PROJECT=ci-cd
oc delete -f ../manifests/backend-build-pipeline.yaml -n ${CICD_PROJECT}
oc delete -f ../manifests/backend-release-pipeline.yaml -n ${CICD_PROJECT}
oc delete -f ../manifests/backend-release-uat-pipeline.yaml -n ${CICD_PROJECT}
oc delete -f ../manifests/backend-release-prod-pipeline.yaml -n ${CICD_PROJECT}
