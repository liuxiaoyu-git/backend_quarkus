#!/bin/bash
PROJECT=ci-cd
JENKINS_SLAVE=quarkus-maven-slave
REGISTRY=quay.io
IMAGE=quarkus/centos-quarkus-maven
TAG=19.2.1
oc import-image ${JENKINS_SLAVE}:${TAG} \
--from=${REGISTRY}/${IMAGE}:${TAG} -n ${PROJECT} \
--scheduled \
--confirm