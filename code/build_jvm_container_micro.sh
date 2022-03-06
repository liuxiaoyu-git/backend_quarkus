#!/bin/sh
CONTAINER_NAME=backend
TAG=micro
if [ $# -lt 1 ];
then
   echo "Usage: build_jvm_container.sh <TAG>"
   exit 1
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
$CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.jvm.micro \
-t ${CONTAINER_NAME}:${TAG} .
