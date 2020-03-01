#!/bin/sh 
set -x
APP_NAME=backend
BASE_IMAGE=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
CONTEXT_DIR=code 
APP_REPOSITORY=https://gitlab.com/ocp-demo/backend_quarkus.git

# To build the image on OpenShift
oc new-app \
${BASE_IMAGE}~${APP_REPOSITORY} \
--context-dir=${CONTEXT_DIR} \
--name=${APP_NAME}

# View build log
oc logs -f bc/${APP_NAME}

# To create the route
oc expose svc/${APP_NAME}

# Get the route URL
# export URL="http://$(oc get route | grep ${APP_NAME} | awk '{print $2}')"
# curl $URL