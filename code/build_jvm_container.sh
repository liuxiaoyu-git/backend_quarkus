#!/bin/sh
CONTAINER_NAME=backend
if [ $# -lt 1 ];
then
   echo "Usage: build_jvm_container.sh <TAG>"
   exit 1
fi
if [ $# -gt 1 ];
then
   DOCKERFILE=$2
else
   DOCKERFILE=jvm
fi
TAG=$1
echo "Build with tag $TAG"
mvn clean package -DskipTests=true
CONTAINER_RUNTIME=podman
podman --version 1>/dev/null 2>&1
if [ $? -ne 0 ];
then
   CONTAINER_RUNTIME=docker 
fi
$CONTAINER_RUNTIME build --platform linux/amd64 -f src/main/docker/Dockerfile.$DOCKERFILE \
-t ${CONTAINER_NAME}:${TAG} .
jq --help > /dev/null
if [ $? -eq 0 ];
then
   ARCH=$($CONTAINER_RUNTIME inspect ${CONTAINER_NAME}:${TAG} | jq '.[0].Architecture' | sed 's/\"//g')
   printf "${CONTAINER_NAME}:${TAG} architecture is $ARCH"
fi