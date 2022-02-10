#!/bin/sh
PROJECT=ci-cd
JENKINS_SLAVE=maven36-with-tools
MAVEN_VERSION=3.6.3
JMETER_VERSION=5.4.1
echo "################  ${JENKINS_SLAVE} ##################"
oc new-build --strategy=docker -D $'FROM quay.io/openshift/origin-jenkins-agent-maven:4.4 \n
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
   mkdir -p /opt/rox && \ \n
   curl -L -o /opt/rox/roxctl https://mirror.openshift.com/pub/rhacs/assets/latest/bin/Linux/roxctl && \ \n
   chmod -R 755 /opt/rox/roxctl && \ \n
   chown -R 1001:0 /opt/rox/roxctl && \ \n
   curl -L -o /tmp/nexus-cli https://s3.eu-west-2.amazonaws.com/nexus-cli/1.0.0-beta/linux/nexus-cli  && \ \n
   mkdir -p /opt/nexus-cli && \ \n
   mv /tmp/nexus-cli /opt/nexus-cli && \ \n
   chmod -R 755 /opt/nexus-cli/nexus-cli && \ \n
   chown -R 1001:0 /opt/nexus-cli && \ \n
   curl -L -o /tmp/jmeter.tgz https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.4.1.tgz && \ \n
   tar -C /opt -xf /tmp/jmeter.tgz && \ \n
   rm -f /tmp/jmeter.tgz && \ \n
   chmod -R 755 /opt/apache-jmeter-5.4.1 && \ \n
   chown -R 1001:0 /opt/apache-jmeter-5.4.1 && \ \n
   DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install skopeo podman buildah && yum clean all   \n
   ENV PATH=/opt/apache-maven-3.6.3/bin:/opt/nexus-cli:/opt/apache-jmeter-5.4.1/bin:/opt/rox:$PATH \n
   USER 1001' --name=${JENKINS_SLAVE} -n ${PROJECT}
echo "Wait 15 sec for build to start"
sleep 15
oc logs build/${JENKINS_SLAVE}-1 -f -n ${PROJECT}
oc get build/${JENKINS_SLAVE}-1 -n ${PROJECT}
