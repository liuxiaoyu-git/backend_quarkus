#!/bin/sh
PROJECT=ci-cd
JENKINS_SLAVE=quarkus-maven-slave
oc new-build --strategy=docker \
-D $'FROM quay.io/quarkus/centos-quarkus-maven:19.2.1\n
   USER root\n
   RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ \n
   curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ \n
   curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ \n
   chmod -R 755 /home/quarkus && \ \n
   chown -R quarkus:0  /home/quarkus && \ \n
   yum -y --setopt=tsflags=nodocs  install skopeo && yum clean all\n
   USER quarkus' --name=${JENKINS_SLAVE} -n ${PROJECT}
echo "Wait 5 sec for build to start"
sleep 5
oc logs build/${JENKINS_SLAVE}-1 -f -n ${PROJECT}
oc get build/${JENKINS_SLAVE}-1 -n ${PROJECT}
# PROJECT=ci-cd
# JENKINS_SLAVE=quarkus-maven-slave
# REGISTRY=quay.io
# IMAGE=quarkus/centos-quarkus-maven
# TAG=19.2.1
# oc import-image ${JENKINS_SLAVE} \
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
