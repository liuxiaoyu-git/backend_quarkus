#!/bin/bash
mvn verify -Pnative
mvn clean package -Pnative  -Dquarkus.native.container-build=true
#mvn package -Pnative -Dquarkus.native.container-runtime=podman
