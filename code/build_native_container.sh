#!/bin/bash
CONTAINER_NAME=backend-native
echo "*" > .dockerignore
echo "!src/*" >> .dockerignore
echo "!pom.xml" >> .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore
docker build -f src/main/docker/Dockerfile.multistage \
-t ${CONTAINER_NAME} .
echo "*" > .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore

