#!/bin/bash
set -x
oc new-project ci-cd --display-name="CI/CD Tools"
oc new-app sonatype/nexus3:latest --name=nexus
oc expose svc nexus
oc rollout pause dc nexus
oc patch dc nexus --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set resources dc nexus --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
oc set volume dc/nexus --add --overwrite --name=nexus-pv-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc --claim-size=4Gi
oc set probe dc/nexus --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/
oc rollout resume dc nexus 
echo "****** Press Ctrl-C when nexus pod is started *****"
watch oc get pods
export NEXUS_POD=$(oc get pods | grep nexus | grep -v deploy | awk '{print $1}')
export NEXUS_PASSWORD=$(oc rsh $NEXUS_POD cat /nexus-data/admin.password)
#curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
#chmod +x setup_nexus3.sh
./setup_nexus3.sh admin $NEXUS_PASSWORD http://$(oc get route nexus --template='{{ .spec.host }}')
oc expose dc nexus --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000
oc new-app --template=postgresql-persistent --param POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param VOLUME_CAPACITY=4Gi --labels=app=sonarqube_db
watch oc get pods
oc new-app --docker-image=quay.io/gpte-devops-automation/sonarqube:7.9.1 --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube
oc rollout pause dc sonarqube
oc expose service sonarqube
oc set volume dc/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc --claim-size=1Gi
oc set resources dc sonarqube --limits=memory=3Gi,cpu=2 --requests=memory=2Gi,cpu=1
oc patch dc sonarqube --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 --get-url=http://:9000/about
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
oc patch dc/sonarqube --type=merge -p '{"spec": {"template": {"metadata": {"labels": {"tuned.openshift.io/elasticsearch": "true"}}}}}'
oc rollout resume dc sonarqube
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc set resources dc jenkins --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
oc new-build --strategy=docker -D $'FROM quay.io/openshift/origin-jenkins-agent-maven:4.1.0\n
   USER root\n
   RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ \n
   curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ \n
   curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ \n
   DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all\n
   USER 1001' --name=mvn-with-skopeo
echo "********** Jenkins URL = $(oc get route jenkins -n ci-cd -o jsonpath='{.spec.host}')"
echo "********** NEXUS URL = $(oc get route nexus -n ci-cd -o jsonpath='{.spec.host}') "
echo "********** NEXUS Password = ${NEXUS_PASSWORD} **************************"
echo "********** Record this password and change it via web console **********"
