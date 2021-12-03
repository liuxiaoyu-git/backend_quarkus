#!/bin/bash
JAVA_PACKAGE=java-11-openjdk-headless
RUN_JAVA_VERSION=1.3.8
LANG='en_US.UTF-8'
LANGUAGE='en_US:en'
microcontainer=$(buildah from registry.access.redhat.com/ubi8/ubi-micro)
micromount=$(buildah mount $microcontainer)
microjavajdk=quay.io/voravitl/backend:micro
yum install --installroot $micromount --nodocs -y \
    curl ca-certificates ${JAVA_PACKAGE}
yum clean all --installroot $micromount
buildah config --env JAVA_PACKAGE="java-11-openjdk-headless" --env LANG="en_US.UTF-8" \
               --env RUN_JAVA_VERSION="1.3.8" --env LANGUAGE="en_US:en" \
	       --env JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager" \
$microcontainer
buildah run $microcontainer mkdir /deployments
buildah run $microcontainer curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh
#buildah run $microcontainer echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/conf/security/java.security
buildah copy $microcontainer target/quarkus-app/lib/ /deployments/lib/
buildah copy $microcontainer target/quarkus-app/app/ /deployments/app/
buildah copy $microcontainer target/quarkus-app/quarkus/ /deployments/quarkus/
buildah copy $microcontainer target/quarkus-app/*.jar /deployments/
buildah run $microcontainer chown -R 1001 /deployments/lib
buildah run $microcontainer chown -R 1001 /deployments/app
buildah run $microcontainer chown -R 1001 /deployments/quarkus
buildah run $microcontainer chown 1001 /deployments/quarkus-run.jar
buildah run $microcontainer chown 1001 /deployments/run-java.sh
buildah run $microcontainer chmod 540 /deployments/run-java.sh
buildah config --port 80 $microcontainer
buildah config --user 1001
buildah config --cmd "/deployments/run-java.sh" $microcontainer
buildah umount $microcontainer
buildah commit $microcontainer $microjavajdk
# For non-root 
# buildah unshare ./backend-ubi-micro.sh
