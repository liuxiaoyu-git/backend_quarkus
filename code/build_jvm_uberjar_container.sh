#!/bin/sh
CONTAINER_NAME=backend
TAG=uber-jar
CONTAINER_RUNTIME=podman
podman --version 1>/dev/null 2>&1
if [ $? -ne 0 ];
then
   CONTAINER_RUNTIME=docker 
fi
mvn clean package -DskipTests=true -Dquarkus.package.type=uber-jar
$CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.jvm_uberjar \
-t ${CONTAINER_NAME}:${TAG} .