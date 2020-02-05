#!/bin/bash
CONTAINER_NAME=backend
echo "*" > .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore
docker build -f src/main/docker/Dockerfile.jvm \
-t ${CONTAINER_NAME} .

