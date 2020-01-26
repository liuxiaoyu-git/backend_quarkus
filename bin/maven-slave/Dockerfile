#FROM registry.redhat.io/openshift3/jenkins-slave-base-rhel7
FROM quay.io/openshift/origin-jenkins-agent-base:v4.0

# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-agent-maven-35-with-tools-rhel7-container" \
      name="origin-jenkins-agent-base:v4.0" \
      version="4.0" \
      architecture="x86_64" \
      io.k8s.display-name="Jenkins Agent Maven with Tools" \
      io.k8s.description="The jenkins agent maven with skopeo" \
      io.openshift.tags="openshift,jenkins,agent,maven,skopeo"

ENV SONAR_VERSION_1001=3.3.0.1492 \
    JMETER_VERSION_1001=5.1.1 \
    JMETER_PATH=$HOME/apache-jmeter \
    JFROG_PATH=$HOME/jfrog-cli \
    SONAR_PATH=$HOME/sonar-scanner
    # GO_VERSION_1001=1.12.1 \
    # GO_PATH=$HOME/go 

ENV PATH=/bin:$PATH:${JMETER_PATH}/bin:$SONAR_PATH/bin:${JFROG_PATH}

WORKDIR /home/jenkins

# Install Maven 3.6.3
RUN curl -L -o /tmp/apache-maven-3.6.3-bin.zip https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip && \
    unzip /tmp/apache-maven-3.6.3-bin.zip && \
    mv 
# Install Sonar Scanner
RUN if [ -z $SONAR_VERSION ] ; then SONAR_VERSION=${SONAR_VERSION_1001} ; fi && \
    curl -L -o /tmp/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}.zip && \
    unzip /tmp/sonar-scanner.zip && \
    mv sonar-scanner-* $HOME/sonar-scanner && \
    chmod 755 $HOME/sonar-scanner && \
    #chown -R 1001 $HOME/sonar-scanner/bin/sonar-scanner && \
    rm -rf /tmp/sonar-scanner.zip



RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001
