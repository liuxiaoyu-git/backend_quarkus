#!/bin/sh
NEXUS=$1
USER=$2
PASSWORD=$3
IMAGE_NAME=$4
curl -X GET \
"$NEXUS/service/rest/v1/search?sort=version&direction=desc&repository=docker&docker.imageName=${IMAGE_NAME}" \
-H "accept: application/json" \
-u $USER:$PASSWORD | \
grep version | \
awk -F':' '{print $2}' | \
sed s/\"//g | \
sed s/,//
