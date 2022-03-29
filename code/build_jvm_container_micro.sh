#!/bin/sh
echo "Build Base Image"
JAVA_PACKAGE=java-11-openjdk-headless
RUN_JAVA_VERSION=1.3.8
LANG='en_US.UTF-8'
LANGUAGE='en_US:en'
microcontainer=$(buildah from registry.access.redhat.com/ubi8/ubi-micro)
micromount=$(buildah mount $microcontainer)
microjavajdk=ubi-micro-openjdk11:latest
yum install --installroot $micromount --nodocs -y \
    ca-certificates ${JAVA_PACKAGE} curl
yum clean all --installroot $micromount
buildah config --env JAVA_PACKAGE="java-11-openjdk-headless" --env LANG="en_US.UTF-8" \
        --env RUN_JAVA_VERSION="1.3.8" --env LANGUAGE="en_US:en" \--env JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager" \
        $microcontainer
buildah run $microcontainer mkdir /deployments
buildah run $microcontainer curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh
buildah run $microcontainer echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/conf/security/java.security
buildah run $microcontainer chown 1001 /deployments/run-java.sh
buildah run $microcontainer chmod 540 /deployments/run-java.sh
yum remove --installroot $micromount -y curl
buildah umount $microcontainer
buildah commit $microcontainer $microjavajdk

CONTAINER_NAME=backend
TAG=micro
# if [ $# -lt 1 ];
# then
#    echo "Usage: build_jvm_container.sh <TAG>"
#    exit 1
# fi
# TAG=$1
echo "Build with tag $TAG"
mvn clean package -DskipTests=true
CONTAINER_RUNTIME=podman
podman --version 1>/dev/null 2>&1
if [ $? -ne 0 ];
then
   CONTAINER_RUNTIME=docker
fi
$CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.jvm.micro \
-t ${CONTAINER_NAME}:${TAG} .
