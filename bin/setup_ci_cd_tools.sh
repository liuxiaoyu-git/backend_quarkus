#!/bin/bash
START_BUILD=$(date +%s)
SONARQUBE_VERSION=7.9.2
NEXUS_VERSION=3.37.3
#NEXUS_VERSION=3.30.1
CICD_PROJECT=ci-cd
DEV_PROJECT=dev
PROD_PROJECT=prod
STAGE_PROJECT=stage
UAT_PROJECT=uat
NEXUS_PVC_SIZE="300Gi"
JENKINS_PVC_SIZE="10Gi"
SONAR_PVC_SIZE="10Gi"
CICD_NEXUS_USER=jenkins
CICD_NEXUS_USER_SECRET=$(echo $CICD_NEXUS_USER|base64 -)
function check_pod(){
    sleep 60
    READY="NO"
    POD=$(oc get pods  -n $CICD_PROJECT --no-headers| grep $1 | grep -v deploy | head -n 1 | awk '{print $1}')
    while [ $READY != "true" ];
    do 
        echo "Current Status: ${MESSAGE}"
        clear;cat $1.txt;sleep 3;clear;cat wait.txt;sleep 2                 
        READY=$(oc get pod $POD -n $CICD_PROJECT -o jsonpath='{.status.containerStatuses[0].ready}')
    done 
}
function add_nexus3_npmproxy_repo() {
  local _REPO_ID=$1
  local _REPO_URL=$2
  local _NEXUS_USER=$3
  local _NEXUS_PWD=$4
  local _NEXUS_URL=$5

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_REPO_ID",
  "type": "groovy",
  "content": "repository.createNpmProxy('$_REPO_ID','$_REPO_URL')"
}
EOM

  curl -k -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_REPO_ID/run"
}

function add_nexus3_nugetproxy_repo() {
  local _REPO_ID=$1
  local _REPO_URL=$2
  local _NEXUS_USER=$3
  local _NEXUS_PWD=$4
  local _NEXUS_URL=$5

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_REPO_ID",
  "type": "groovy",
  "content": "repository.createNugetProxy('$_REPO_ID','$_REPO_URL')"
}
EOM

  curl -k -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_REPO_ID/run"
}

#
# Add a Proxy Repo to Nexus3
# add_nexus3_proxy_repo [repo-id] [repo-url] [nexus-username] [nexus-password] [nexus-url]
#
function add_nexus3_proxy_repo() {
  local _REPO_ID=$1
  local _REPO_URL=$2
  local _NEXUS_USER=$3
  local _NEXUS_PWD=$4
  local _NEXUS_URL=$5

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_REPO_ID",
  "type": "groovy",
  "content": "repository.createMavenProxy('$_REPO_ID','$_REPO_URL')"
}
EOM

  curl -k  -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k  -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_REPO_ID/run"
}

#
# Add a Release Repo to Nexus3
# add_nexus3_release_repo [repo-id] [nexus-username] [nexus-password] [nexus-url]
#
function add_nexus3_release_repo() {
  local _REPO_ID=$1
  local _NEXUS_USER=$2
  local _NEXUS_PWD=$3
  local _NEXUS_URL=$4

  # Repository createMavenHosted(final String name,
  #                                final String blobStoreName,
  #                                final boolean strictContentTypeValidation,
  #                                final VersionPolicy versionPolicy,
  #                                final WritePolicy writePolicy,
  #                                final LayoutPolicy layoutPolicy);

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_REPO_ID",
  "type": "groovy",
  "content": "import org.sonatype.nexus.blobstore.api.BlobStoreManager\nimport org.sonatype.nexus.repository.storage.WritePolicy\nimport org.sonatype.nexus.repository.maven.VersionPolicy\nimport org.sonatype.nexus.repository.maven.LayoutPolicy\nrepository.createMavenHosted('$_REPO_ID',BlobStoreManager.DEFAULT_BLOBSTORE_NAME, false, VersionPolicy.RELEASE, WritePolicy.ALLOW, LayoutPolicy.PERMISSIVE)"
}
EOM

  curl -k  -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k  -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_REPO_ID/run"
}

#
# add_nexus3_group_proxy_repo [comma-separated-repo-ids] [group-id] [nexus-username] [nexus-password] [nexus-url]
#
function add_nexus3_group_proxy_repo() {
  local _REPO_IDS=$1
  local _GROUP_ID=$2
  local _NEXUS_USER=$3
  local _NEXUS_PWD=$4
  local _NEXUS_URL=$5

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_GROUP_ID",
  "type": "groovy",
  "content": "repository.createMavenGroup('$_GROUP_ID', '$_REPO_IDS'.split(',').toList())"
}
EOM

  curl -k  -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k  -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_GROUP_ID/run"
}

#
# Add a Docker Registry Repo to Nexus3
# add_nexus3_docker_repo [repo-id] [repo-port] [nexus-username] [nexus-password] [nexus-url]
#
function add_nexus3_docker_repo() {
  local _REPO_ID=$1
  local _REPO_PORT=$2
  local _NEXUS_USER=$3
  local _NEXUS_PWD=$4
  local _NEXUS_URL=$5

  read -r -d '' _REPO_JSON << EOM
{
  "name": "$_REPO_ID",
  "type": "groovy",
  "content": "repository.createDockerHosted('$_REPO_ID',$_REPO_PORT,null)"
}
EOM

  curl -k  -v -H "Accept: application/json" -H "Content-Type: application/json" -d "$_REPO_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/"
  curl -k  -v -X POST -H "Content-Type: text/plain" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/v1/script/$_REPO_ID/run"
}

function add_nexus3_user() {
  local _JENKINS=$4
  local _PWD=$5
  local _NEXUS_USER=$1
  local _NEXUS_PWD=$2
  local _NEXUS_URL=$3

  read -r -d '' _USER_JSON << EOM
{
  "userId": "${_JENKINS}",
  "firstName": "${_JENKINS}",
  "lastName": "CI/CD",
  "emailAddress": "${_JENKINS}@example.com",
  "password": "${_PWD}",
  "status": "active",
  "roles": [
    "nx-admin"
  ]
}
EOM
  curl -k  -v  -H "accept: application/json" -H "Content-Type: application/json" -d "$_USER_JSON" -u "$_NEXUS_USER:$_NEXUS_PWD" "${_NEXUS_URL}/service/rest/beta/security/users"
}
echo "Add Nexus service to insecure registries list"
oc patch image.config.openshift.io/cluster -p \
'{"spec":{"registrySources":{"insecureRegistries":["nexus-registry.ci-cd.svc.cluster.local"]}}}' --type='merge'
oc project ${CICD_PROJECT}
clear;echo "Setup Jenkins..."
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi \
--param VOLUME_CAPACITY=${JENKINS_PVC_SIZE} --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc set resources dc jenkins --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m
oc label dc jenkins app.kubernetes.io/name=Jenkins -n ${CICD_PROJECT}
oc label dc jenkins app.openshift.io/runtime=jenkins -n ${CICD_PROJECT}
check_pod "jenkins"
clear;echo "Setup Nexus..."
oc new-app sonatype/nexus3:${NEXUS_VERSION} --name=nexus -n ${CICD_PROJECT}
oc create route edge nexus --service=nexus --port=8081
oc rollout pause deployment nexus -n ${CICD_PROJECT}
oc set resources deployment nexus --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m -n ${CICD_PROJECT}
oc set volume deployment/nexus --remove --confirm -n ${CICD_PROJECT}
oc set volume deployment/nexus --add --overwrite --name=nexus-pv-1 \
--mount-path=/nexus-data/ --type persistentVolumeClaim \
--claim-name=nexus-pvc --claim-size=${NEXUS_PVC_SIZE} -n ${CICD_PROJECT}
oc set probe deployment/nexus --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok -n ${CICD_PROJECT}
oc set probe deployment/nexus --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/ -n ${CICD_PROJECT}
oc label deployment nexus app.kubernetes.io/part-of=Registry -n ${CICD_PROJECT}
oc rollout resume deployment nexus -n ${CICD_PROJECT}
check_pod "nexus"
clear;echo "Create Nexus repositories..."
sleep 30
NEXUS_POD=$(oc get pods | grep nexus |grep -v deploy |grep -v Termination| grep Running | awk '{print $1}')
oc cp $NEXUS_POD:/nexus-data/etc/nexus.properties nexus.properties
echo nexus.scripts.allowCreation=true >>  nexus.properties
oc cp nexus.properties $NEXUS_POD:/nexus-data/etc/nexus.properties
rm -f nexus.properties
oc delete pod $NEXUS_POD
check_pod "nexus"
NEXUS_POD=$(oc get pods | grep nexus | grep -v deploy |grep Running| awk '{print $1}')
NEXUS_PASSWORD=$(oc exec $NEXUS_POD -- cat /nexus-data/admin.password)
CICD_NEXUS_PASSWORD=${NEXUS_PASSWORD}-$(date +%s)
NEXUS_URL=https://$(oc get route nexus --template='{{ .spec.host }}')
add_nexus3_proxy_repo redhat-ga https://maven.repository.redhat.com/ga/ admin $NEXUS_PASSWORD $NEXUS_URL
add_nexus3_group_proxy_repo redhat-ga,maven-central,maven-releases,maven-snapshots maven-all-public admin $NEXUS_PASSWORD $NEXUS_URL
add_nexus3_docker_repo docker 5000 admin $NEXUS_PASSWORD $NEXUS_URL
add_nexus3_user admin $NEXUS_PASSWORD $NEXUS_URL $CICD_NEXUS_USER $CICD_NEXUS_PASSWORD
add_nexus3_npmproxy_repo npm https://registry.npmjs.org/ admin $NEXUS_PASSWORD $NEXUS_URL
add_nexus3_nugetproxy_repo nuget https://api.nuget.org/v3/index.json admin $NEXUS_PASSWORD $NEXUS_URL
# https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
# ./setup_nexus3.sh admin $NEXUS_PASSWORD \
# https://$(oc get route nexus --template='{{ .spec.host }}') \
# ${CICD_NEXUS_USER} \
# ${CICD_NEXUS_PASSWORD}
echo "expose port 5000 for container registry"
oc expose deployment nexus --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000
NEXUS_PASSWORD=$(oc exec $NEXUS_POD -- cat /nexus-data/admin.password)
CICD_NEXUS_PASSWORD_SECRET=$(echo ${CICD_NEXUS_PASSWORD}|base64 -)
clear;echo "Setup PostgreSQL for SonarQube..."
oc new-app  --template=postgresql-persistent \
--param POSTGRESQL_USER=sonar \
--param POSTGRESQL_PASSWORD=sonar \
--param POSTGRESQL_DATABASE=sonar \
--param VOLUME_CAPACITY=${SONAR_PVC_SIZE} \
--labels=app=sonarqube_db,app.openshift.io/runtime=postgresql

check_pod "postgresql"
clear;echo "Setup SonarQube..."
oc new-app  --docker-image=quay.io/gpte-devops-automation/sonarqube:$SONARQUBE_VERSION --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube
oc rollout pause deployment sonarqube
oc annotate deployment sonarqube 'app.openshift.io/connects-to=[{"apiVersion":"apps.openshift.io/v1","kind":"DeploymentConfig","name":"postgresql"}]'
oc label deployment sonarqube app.kubernetes.io/part-of=Code-Quality -n ${CICD_PROJECT}
#oc expose svc sonarqube
oc create route edge sonarqube --service=sonarqube --port=9000
oc set volume deployment/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc --claim-size=1Gi
oc set resources deployment sonarqube --limits=memory=3Gi,cpu=2 --requests=memory=2Gi,cpu=1
oc set probe deployment/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 --get-url=http://:9000/about
oc set probe deployment/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
oc patch deployment/sonarqube --type=merge -p '{"spec": {"template": {"metadata": {"labels": {"tuned.openshift.io/elasticsearch": "true"}}}}}'
oc label dc postgresql app.kubernetes.io/part-of=Code-Quality -n ${CICD_PROJECT}
oc label dc postgresql app.kubernetes.io/name=posgresql -n ${CICD_PROJECT}
oc rollout resume deployment sonarqube
check_pod "sonarqube"
clear;echo "Create secrets for Jenkins to access Nexus"
oc create -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: nexus-credential
type: Opaque 
data:
  username: ${CICD_NEXUS_USER_SECRET}
  password: ${CICD_NEXUS_PASSWORD_SECRET}
EOF

NEXUS_REGISTRY=$(oc get route nexus-registry -n ${CICD_PROJECT} -o jsonpath='{.spec.host}')
PROJECTS=($CICD_PROJECT $DEV_PROJECT $STAGE_PROJECT $UAT_PROJECT $PROD_PROJECT)
for project in  "${PROJECTS[@]}"
do
    echo "Create registry secret for $project"
     oc create secret docker-registry nexus-registry --docker-server=$NEXUS_REGISTRY \
     --docker-username=$CICD_NEXUS_USER \
     --docker-password=$CICD_NEXUS_PASSWORD \
     --docker-email=unused \
     -n $project
     oc create secret docker-registry nexus-svc-registry --docker-server=nexus-registry.svc.cluster.local:5000 \
     --docker-username=$CICD_NEXUS_USER \
     --docker-password=$CICD_NEXUS_PASSWORD \
     --docker-email=unused \
     -n $project
    #oc get secret nexus-credential -o yaml -n $CICD_PROJECT | grep -v '^\s*namespace:\s' | oc create -n $project -f -
done
clear;echo "Link Nexus' secret to puller"
for project in "${PROJECTS[@]}"
do
    echo "Link secrets for $project"
    oc secrets link default nexus-registry -n $project --for=pull
    oc secrets link default nexus-svc-registry -n $project --for=pull
done
clear;echo "Link Nexus' secret to builder"
oc secrets link builder nexus-registry -n $CICD_PROJECT
oc secrets link builder nexus-svc-registry -n $CICD_PROJECT
END_BUILD=$(date +%s)
BUILD_TIME=$(expr ${END_BUILD} - ${START_BUILD})
echo ${NEXUS_PASSWORD} > nexus_password.txt
echo ${CICD_NEXUS_PASSWORD} >> nexus_password.txt
clear
echo "Jenkins URL = $(oc get route jenkins -n ${CICD_PROJECT} -o jsonpath='{.spec.host}')"
echo "NEXUS URL = $(oc get route nexus -n ${CICD_PROJECT} -o jsonpath='{.spec.host}') "
echo "NEXUS Password = ${NEXUS_PASSWORD}"
echo "Nexus password is stored at bin/nexus_password.txt"
echo "Jenkins will use user/password store in secret nexus-credential to access nexus"
echo "Login to Nexus with admin and jenkins"
echo "Record this password and change it via web console"
echo "Start build pipeline and deploy to dev project by run start_build_pipeline.sh"
echo "Elasped time to build is $(expr ${BUILD_TIME} / 60 ) minutes"
echo "Setup jenkins slave with setup_maven36_slave.sh"
