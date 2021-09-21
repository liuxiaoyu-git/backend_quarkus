#!/bin/sh
CONTAINER_NAME=backend
TAG=trace
mvn clean package -DskipTests=true
docker build -f src/main/docker/Dockerfile.jvm \
-t ${CONTAINER_NAME}:${TAG} .
