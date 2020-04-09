#!/bin/sh
CONTAINER_NAME=backend-native
TAG=v1
# Use native container build
# mvn test
mvn clean package -Dquarkus.native.container-build=true -DskipTests=true  -Pnative 
docker build -f src/main/docker/Dockerfile.native \
-t ${CONTAINER_NAME}:${TAG} .