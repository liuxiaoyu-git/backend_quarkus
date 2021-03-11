#!/bin/bash
CICD_PROJECT=ci-cd
DEV_PROJECT=dev
PROD_PROJECT=prod
STAGE_PROJECT=stage
UAT_PROJECT=uat
NEXUS_REGISTRY=$(oc get route nexus-registry -n ${CICD_PROJECT} -o jsonpath='{.spec.host}')
CICD_NEXUS_USER=jenkins
CICD_NEXUS_PASSWORD=$(cat nexus_password.txt|tail -n 1)
PROJECTS=($DEV_PROJECT $STAGE_PROJECT $UAT_PROJECT $PROD_PROJECT)
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

for project in "${PROJECTS[@]}"
do
    echo "Link secrets for $project"
    oc secrets link default nexus-registry -n $project --for=pull
    oc secrets link default nexus-svc-registry -n $project --for=pull
done
