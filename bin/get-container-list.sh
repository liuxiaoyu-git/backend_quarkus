#!/bin/sh
curl -X GET "https://nexus-ci-cd.apps.cluster-bkk19-0fd1.bkk19-0fd1.example.opentlc.com/service/rest/v1/search?sort=version&direction=desc&repository=docker&docker.imageName=backend" -H "accept: application/json" -u admin:r3dh4t1! | grep version | awk -F':' '{print $2}' |\nsed s/\"//g | sed s/,//
