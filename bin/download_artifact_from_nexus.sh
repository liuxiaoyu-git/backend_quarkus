#!/bin/sh
curl -X GET -G https://nexus-ci-cd.apps.cluster-pttict-6590.pttict-6590.example.opentlc.com/service/rest/v1/search/assets \
  -d repository=releases \
  -d maven.groupId=com.example.quarkus \
  -d maven.artifactId=backend \
  -d maven.baseVersion=1.0.0 \
  -d maven.extension=jar | grep downloadUrl | awk -F" : " '{print $2}' | sed s/\"//g | sed s/,// | xargs curl --output test.jar
