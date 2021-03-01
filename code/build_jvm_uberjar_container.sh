#!/bin/sh
CONTAINER_NAME=backend-uber
TAG=$1
mvn clean package -DskipTests=true -Dquarkus.package.uber-jar=true
echo "*" > .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore
docker build -f src/main/docker/Dockerfile.jvm_uberjar \
-t ${CONTAINER_NAME}:${TAG} .
rm -f .dockerignore