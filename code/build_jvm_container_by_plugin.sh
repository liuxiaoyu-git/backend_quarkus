#!/bin/sh
# mvn quarkus:add-extension -Dextensions="container-image-docker"
PUSH_TO_REGISTRY=true
IMAGE_NAME=backend
IMAGE_GROUP=voravitl
IMAGE_TAG=v3
REGISTRY=quay.io
TEST=false
IMAGE_BUILD=true
mvn clean package \
-Dquarkus.native.container-build=true \
-DSkipTests=${TEST} \
-Dquarkus.container-image.build=${IMAGE_BUILD} \
-Dquarkus.container-image.push=${PUSH_TO_REGISTRY} \
-Dquarkus.container-image.registry=${REGISTRY} \
-Dquarkus.container-image.name=${IMAGE_NAME} \
-Dquarkus.container-image.group=${IMAGE_GROUP} \
-Dquarkus.container-image.tag=${IMAGE_TAG}
