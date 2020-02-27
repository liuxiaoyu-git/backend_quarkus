#!/bin/sh
NEXUS=nexus-ci-cd.apps.cluster-pttict-6590.pttict-6590.example.opentlc.com
PROTOCOL=https
REPOSITORY=releases
GROUPID=com.example.quarkus 
ARTIFACTID=backend
VERSION=1.0.0
URL=${PROTOCOL}://${NEXUS}/service/rest/v1/search/assets
JAR_URL=$(curl -X GET -G ${URL} -d repository=${REPOSITORY} -d maven.groupId=${GROUPID} -d maven.artifactId=${ARTIFACTID} -d maven.baseVersion=${VERSION} -d maven.extension=jar | grep downloadUrl | awk -F" : " '{print $2}' | sed s/\"//g | sed s/,//)
curl --output ${ARTIFACTID}-${VERSION}.jar $JAR_URL