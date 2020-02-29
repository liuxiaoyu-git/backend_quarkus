#!/bin/sh
CONTAINER_NAME=backend
TAG=v1
mvn clean package -DskipTests=true -Dquarkus.package.uber-jar=true
echo "*" > .dockerignore
echo "!target/*-runner.jar" >> .dockerignore
docker build -f src/main/docker/Dockerfile.jvm \
-t ${CONTAINER_NAME}:${TAG} .