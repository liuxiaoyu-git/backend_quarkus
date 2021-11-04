#!/bin/sh
CONTAINER_NAME=backend
TAG=$1
mvn clean package -DskipTests=true
CONTAINER_RUNTIME=podman
podman --version 1>/dev/null 2>&1
if [ $? -ne 0 ];
then
   CONTAINER_RUNTIME=docker 
fi
# echo "*" > .dockerignore
# echo "!target/*-runner" >>.dockerignore
# echo "!target/*-runner.jar" >> .dockerignore
# echo "!target/lib/*" >> .dockerignore
$CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.jvm \
-t ${CONTAINER_NAME}:${TAG} .
