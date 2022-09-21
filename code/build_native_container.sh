#!/bin/sh
CONTAINER_NAME=backend-native
PLATFORM=linux/amd64
TAG=$1
IMAGE=multistage

CONTAINER_RUNTIME=podman
podman --version 1>/dev/null 2>&1
if [ $? -ne 0 ];
then
  CONTAINER_RUNTIME=docker
fi
# Use multistage build
START_BUILD_APP=$(date +%s)
$CONTAINER_RUNTIME build --platform=$PLATFORM -f src/main/docker/Dockerfile.$IMAGE -t backend-native:$TAG .
END_BUILD_APP=$(date +%s)
BUILD_APP_TIME=$(expr ${END_BUILD_APP} - ${START_BUILD_APP})
BUILD_APP_TIME=$(expr ${BUILD_APP_TIME} / 60 )
echo "Elasped time to build container ${BUILD_APP_TIME} minutes"

# if [ $? -ne 0 ];
# then
#   CONTAINER_RUNTIME=docker
#   MAVEN_CLI="clean package -Dquarkus.native.container-build=true -DskipTests=true  -Pnative"
# else
#   MAVEN_CLI="clean package -Pnative -Dquarkus.native.remote-container-build=true -Dquarkus.native.native-image-xmx=5g "
#   #MAVEN_CLI="clean package -Pnative -Dquarkus.native.container-build=true -Dquarkus.native.remote-container-build=true -Dquarkus.native.container-runtime=podman"
#   ##MAVEN_CLI="clean package -Dnative -Dquarkus.native.container-build=true -Dquarkus.native.container-runtime=podman -DskipTests=true"
# fi
# START_BUILD_APP=$(date +%s)
# mvn $MAVEN_CLI
# END_BUILD_APP=$(date +%s)
# START_BUILD_CONTAINER=$(date +%s)
# $CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.native \
# -t ${CONTAINER_NAME}:${TAG} .
# $CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.native-distroless \
# -t ${CONTAINER_NAME}:${TAG}-distroless .
# $CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.native-micro \
# -t ${CONTAINER_NAME}:${TAG}-micro .
# END_BUILD_CONTAINER=$(date +%s)
# BUILD_APP=$(expr ${END_BUILD_APP} - ${START_BUILD_APP})
# BUILD_CONTAINER=$(expr ${END_BUILD_CONTAINER} - ${START_BUILD_CONTAINER})
# echo "Elasped time to build app:${BUILD_APP} sec"
# echo "Elasped time to build container:${BUILD_CONTAINER} sec"
# -Dquarkus.native.builder-image=quay.io/quarkus/ubi-quarkus-mandrel:22.1-java11
# quarkus build --native -Dquarkus.native.container-build=true -Dquarkus.native.remote-container-build=true -Dquarkus.native.builder-image=quay.io/quarkus/ubi-quarkus-mandrel:22.2-java11 -Dquarkus.native.native-image-xmx=6g
