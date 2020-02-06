#!/bin/sh
APP_NAME=backend
PROJECT=prod
DELAY=3
PROD_URL=$(oc get route/${APP_NAME} -n ${PROJECT} -o jsonpath='{.spec.host}')
while [ 1 ];
do
  curl http://${PROD_URL}
  sleep ${DELAY}
  echo ""
done

