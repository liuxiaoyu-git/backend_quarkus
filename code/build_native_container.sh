#!/bin/sh
CONTAINER_NAME=backend-native
TAG=v1
echo "*" > .dockerignore
echo "!src/*" >> .dockerignore
echo "!pom.xml" >> .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore
docker build -f src/main/docker/Dockerfile.multistage \
-t ${CONTAINER_NAME}:${TAG} .
echo "*" > .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore

