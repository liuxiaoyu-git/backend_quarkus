#!/bin/sh
๒
yum clean all --installroot $microcontainer 
buildah config --env JAVA_PACKAGE="java-11-openjdk-headless" --env LANG="en_US.UTF-8" \
        --env RUN_JAVA_VERSION="1.3.8" --env LANGUAGE="en_US:en" \
        --env JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager" \
        $microcontainer
buildah run $microcontainer mkdir /deployments
buildah copy $microcontainer target/quarkus-app/lib/ /deployments
buildah copy $microcontainer target/quarkus-app/*.jar /deployments
buildah copy $microcontainer target/quarkus-app/app/ /deployments
buildah copy $microcontainer target/quarkus-app/quarkus/ /deployments
curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o ./run-java.sh
buildah copy $microcontainer ./run-java.sh /deployments
buildah run $microcontainer echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/conf/security/java.security
buildah run $microcontainer chown -R 1001 /deployments
#buildah run $microcontainer chown 1001 /deployments/run-java.sh
buildah run $microcontainer chmod 540 /deployments/run-java.sh
buildah config --port 8080 $microcontainer
buildah config --entrypoint "/deployments/run-java.sh" $microcontainer
buildah config --user 1001 $microcontainer
buildah umount $microcontainer
buildah commit $microcontainer $backendimage
# if [ $# -lt 1 ];
# then
#    echo "Usage: build_jvm_container.sh <TAG>"
#    exit 1
# fi
# TAG=$1
# echo "Build with tag $TAG"
# mvn clean package -DskipTests=true
# CONTAINER_RUNTIME=podman
# podman --version 1>/dev/null 2>&1
# if [ $? -ne 0 ];
# then
#    CONTAINER_RUNTIME=docker
# fi
# $CONTAINER_RUNTIME build -f src/main/docker/Dockerfile.jvm.micro \
# -t ${CONTAINER_NAME}:${TAG} .