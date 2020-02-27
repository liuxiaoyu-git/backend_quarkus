#!/bin/bash
function check_pod(){
    READY="NO"
    while [ $READY = "NO" ];
    do
        clear
        echo "****** Wait for $1 pod to sucessfully start ******"
        MESSAGE=$(oc get pods  -n ${CICD_PROJECT}| grep $1 | grep -v deploy)
        STATUS=$(echo ${MESSAGE}| awk '{print $2}')
        if [ $(echo -n ${MESSAGE} | wc -c) -gt 0 ];
            then
            echo "Current Status: ${MESSAGE}"
            if [ ${STATUS} = "1/1" ];
            then
                READY="YES"
            else 
                echo "*************   Wait another 5 sec   *************"
                sleep 5
            fi
        else
            oc get pods -n ${CICD_PROJECT} | grep $1
            sleep 5
        fi
    done
}
export CICD_PROJECT=ci-cd
echo "########## Start build Jenkins ##########"
oc new-project ${CICD_PROJECT} --display-name="CI/CD Tools"
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc set resources dc jenkins --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
# No need to wait for jenkins to start
# check_pod "jenkins"
echo "########## Start build Nexus   ##########"
oc new-app sonatype/nexus3:latest --name=nexus -n ${CICD_PROJECT}
#oc expose svc nexus -n ${CICD_PROJECT}
oc create route edge nexus --service=nexus --port=8081
oc rollout pause dc nexus -n ${CICD_PROJECT}
oc patch dc nexus --patch='{ "spec": { "strategy": { "type": "Recreate" }}}' -n ${CICD_PROJECT}
oc set resources dc nexus --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m -n ${CICD_PROJECT}
oc set volume dc/nexus --add --overwrite --name=nexus-pv-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc --claim-size=1Gi -n ${CICD_PROJECT}
oc set probe dc/nexus --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok -n ${CICD_PROJECT}
oc set probe dc/nexus --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/ -n ${CICD_PROJECT}
oc rollout resume dc nexus -n ${CICD_PROJECT}
check_pod "nexus"
# echo "##########   Configure Nexus   ############"
# echo "Wait 10 sec..."
# sleep 10
# export NEXUS_POD=$(oc get pods | grep nexus | grep -v deploy | awk '{print $1}')
# export NEXUS_PASSWORD=$(oc rsh $NEXUS_POD cat /nexus-data/admin.password)
# # https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
# ./setup_nexus3.sh admin $NEXUS_PASSWORD http://$(oc get route nexus --template='{{ .spec.host }}')
# echo "expose port 5000 for container registry"
# oc expose dc nexus --port=5000 --name=nexus-registry
# oc create route edge nexus-registry --service=nexus-registry --port=5000
echo "########   Setup SonarQube   ##########"
oc new-app --template=postgresql-persistent --param POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param VOLUME_CAPACITY=2Gi --labels=app=sonarqube_db
check_pod "postgresql"
oc new-app --docker-image=quay.io/gpte-devops-automation/sonarqube:7.9.1 --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube
oc rollout pause dc sonarqube
#oc expose svc sonarqube
oc create route edge sonarqube --service=sonarqube --port=9000
oc set volume dc/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc --claim-size=1Gi
oc set resources dc sonarqube --limits=memory=3Gi,cpu=2 --requests=memory=2Gi,cpu=1
oc patch dc sonarqube --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 --get-url=http://:9000/about
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
oc patch dc/sonarqube --type=merge -p '{"spec": {"template": {"metadata": {"labels": {"tuned.openshift.io/elasticsearch": "true"}}}}}'
oc rollout resume dc sonarqube
check_pod "sonarqube"
# echo "####### Maven 3.5 Jenkins Slave with Skopeo #########"
# oc new-build --strategy=docker -D $'FROM quay.io/openshift/origin-jenkins-agent-maven:4.1.0\n
#    USER root\n
#    RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ \n
#    curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ \n
#    curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ \n
#    DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ \n
#    yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all\n
#    USER 1001' --name=mvn-with-skopeo
echo "##########   Configure Nexus   ############"
echo "Wait 10 sec..."
sleep 10
export NEXUS_POD=$(oc get pods | grep nexus | grep -v deploy | awk '{print $1}')
export NEXUS_PASSWORD=$(oc rsh $NEXUS_POD cat /nexus-data/admin.password)
# https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
./setup_nexus3.sh admin $NEXUS_PASSWORD https://$(oc get route nexus --template='{{ .spec.host }}')
echo "expose port 5000 for container registry"
oc expose dc nexus --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000
echo "###########################################################################################"
echo "Jenkins URL = $(oc get route jenkins -n ${CICD_PROJECT} -o jsonpath='{.spec.host}')"
echo "NEXUS URL = $(oc get route nexus -n ${CICD_PROJECT} -o jsonpath='{.spec.host}') "
echo "NEXUS Password = ${NEXUS_PASSWORD}"
echo "Nexus password is stored at bin/nexus_password.txt"
echo ${NEXUS_PASSWORD} > nexus_password.txt
echo "Record this password and change it via web console"
echo "You need to enable anonymous access"
echo "Start build pipeline and deploy to dev project by run start_build_pipeline.sh"
echo "###########################################################################################"