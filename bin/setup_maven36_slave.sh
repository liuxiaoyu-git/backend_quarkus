#!/bin/sh
PROJECT=ci-cd
JENKINS_SLAVE=maven36-with-tools
MAVEN_VERSION=3.6.3
echo "################  ${JENKINS_SLAVE} ##################"
oc new-build --strategy=docker -D $'FROM quay.io/openshift/origin-jenkins-agent-maven:4.1\n
   USER root\n
   RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ \n
   curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ \n
   curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ \n
   curl -L -o /tmp/apache-maven-3.6.3-bin.tar.gz https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \ \n
   gzip -d /tmp/apache-maven-3.6.3-bin.tar.gz && \ \n
   tar -C /opt -xf /tmp/apache-maven-3.6.3-bin.tar && \ \n
   rm -f /tmp/apache-maven-3.6.3-bin.tar && \ \n
   chmod -R 755 /opt/apache-maven-3.6.3 && \ \n
   chown -R 1001:0 /opt/apache-maven-3.6.3 && \ \n
   DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install podman && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install java-11-openjdk-devel && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all   \n
   ENV PATH=/opt/apache-maven-3.6.3/bin:$PATH \n
   USER 1001' --name=${JENKINS_SLAVE} -n ${PROJECT}
echo "Wait 5 sec for build to start"
sleep 5
oc logs build/${JENKINS_SLAVE}-1 -f -n ${PROJECT}
oc get build/${JENKINS_SLAVE}-1 -n ${PROJECT}
