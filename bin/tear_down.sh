#!/bin/sh
oc delete project ci-cd
oc delete project dev
oc delete project stage
oc delete project uat
oc delete project prod
