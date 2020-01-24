FROM  quay.io/openshift/origin-jenkins-agent-maven:4.1.0
#USER root
# Labels consumed by Red Hat build service
# LABEL com.redhat.component="jenkins-agent-maven-35-with-tools-rhel7-container" \
#       name="openshift3/jenkins-agent-maven-35-with-tools-rhel7" \
#       version="3.11" \
#       architecture="x86_64" \
#       io.k8s.display-name="Jenkins Agent Maven with Tools" \
#       io.k8s.description="The jenkins agent maven and go image with sonar-scanner,jmeter and jfrog" \
#       io.openshift.tags="openshift,jenkins,agent,maven,jfrog,sonar-scanner,jmeter,golang"

ENV MAVEN_VERSION=3.6.3 \
    HOME=/home/jenkins \
    MAVEN_PATH=${HOME}/apache-maven-3.6.3/bin

    # SONAR_VERSION_1001=3.3.0.1492 \
    # JMETER_VERSION_1001=5.1.1 \
    # JMETER_PATH=$HOME/apache-jmeter \
    # JFROG_PATH=$HOME/jfrog-cli \
    # SONAR_PATH=$HOME/sonar-scanner
    # http://us.mirrors.quenda.co/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz

#ENV PATH=${MAVEN_PATH}:/bin:$PATH

WORKDIR /home/jenkins
#WORKDIR /opt

# RUN curl -L  -o /home/jenkins/apache-maven-3.6.3-bin.tar.gz \
#     http://us.mirrors.quenda.co/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
#     tar -xf /home/jenkins/apache-maven-3.6.3-bin.tar.gz && \
#     #mv /tmp/apache-maven-3.6.3 $HOME/apache-maven && \
#     chmod 755 /home/jenkins/apache-maven-3.6.3
#     #rm -rf /home/jenkins/apache-maven-3.6.3-bin.tar.gz


RUN curl -L  -o /home/jenkins/apache-maven-3.6.3-bin.tar.gz \
    http://us.mirrors.quenda.co/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
    # gzip -d /home/jenkins/apache-maven-3.6.3-bin.tar.gz && \
    # tar -xf /home/jenkins/apache-maven-3.6.3-bin.tar && \
    #mv /tmp/apache-maven-3.6.3 $HOME/apache-maven && \
    #chmod -R 755 /opt/apache-maven-3.6.3
    #chown -R 1001:0 /opt/apache-maven-3.6.3
    # rm -rf /home/jenkins/apache-maven-3.6.3-bin.tar  


#RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ 
#    curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ 
#    curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ 
#    DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ 
#    yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001
