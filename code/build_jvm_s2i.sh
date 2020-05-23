#!/bin/sh 
APP_NAME=backend
BASE_IMAGE=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
CONTEXT_DIR=code 
APP_REPOSITORY=https://gitlab.com/ocp-demo/backend_quarkus.git

echo "Check for .s2i/environment"
if [ ! -f .s2i/environment ];
then
    echo ".s2i/environment is missing"
    exit 1
fi
# To build the image on OpenShift
oc new-app \
${BASE_IMAGE}~${APP_REPOSITORY} \
--context-dir=${CONTEXT_DIR} \
--labels=app.kubernetes.io/name=java,app.openshift.io/runtime=quarkus \
--name=${APP_NAME}
echo "##### Wait for 3 sec #####"
sleep 3
# View build log
echo "##### Build Log #####"
oc logs -f bc/${APP_NAME}
# To create the route
oc expose svc/${APP_NAME}
# Get the route URL
echo "URL: http://$(oc get route | grep ${APP_NAME} | awk '{print $2}')"
