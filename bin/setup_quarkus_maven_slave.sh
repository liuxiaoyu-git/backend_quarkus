#!/bin/bash
PROJECT=ci-cd
JENKINS_SLAVE=quarkus-maven-slave
oc new-build --strategy=docker \
-D $'FROM quay.io/quarkus/centos-quarkus-maven:19.2.1\n
USER 1001' \
--name=${JENKINS_SLAVE} -n ${PROJECT}
echo "Wait 5 sec for build to start"
sleep 5
oc logs build/${JENKINS_SLAVE}-1 -f -n ${PROJECT}
oc get build/${JENKINS_SLAVE}-1 -n ${PROJECT}
# PROJECT=ci-cd
# JENKINS_SLAVE=quarkus-maven-slave
# REGISTRY=quay.io
# IMAGE=quarkus/centos-quarkus-maven
# TAG=19.2.1
# oc import-image ${JENKINS_SLAVE}:${TAG} \
# --from=${REGISTRY}/${IMAGE}:${TAG} -n ${PROJECT} \
# --scheduled \
# --confirm

# FROM quay.io/quarkus/centos-quarkus-maven:19.2.1 AS build
# COPY src /usr/src/app/src
# COPY pom.xml /usr/src/app
# USER root
# RUN chown -R quarkus /usr/src/app
# USER quarkus
# RUN mvn -f /usr/src/app/pom.xml -Pnative clean package