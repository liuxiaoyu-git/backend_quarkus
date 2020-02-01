#!/bin/bash
mvn verify -Pnative
mvn clean package -Pnative  -Dquarkus.native.container-build=true
