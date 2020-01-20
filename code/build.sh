#!/bin/sh
oc new-build --binary --name=backend -l app=backend
oc patch bc/backend -p "{\"spec\":{\"strategy\":{\"dockerStrategy\":{\"dockerfilePath\":\"src/main/docker/Dockerfile.jvm\"}}}}"
oc start-build backend --from-dir=. --follow
oc new-app --image-stream=backend:latest
oc rollout pause dc backend
oc set probe dc/backend --readiness --get-url=http://:8080/health/ready --initial-delay-seconds=15 --failure-threshold=1 --period-seconds=10
oc set probe dc/backend --liveness --get-url=http://:8080/health/live --initial-delay-seconds=10 --failure-threshold=3 --period-seconds=10
oc delete configmap backend
oc create configmap backend --from-file=config/application.properties
oc set volume dc/backend --add --name=backend-config \
--mount-path=/deployments/config/application.properties \
--sub-path=application.properties \
--configmap-name=backend
oc expose svc backend
oc rollout resume dc backend
BACKEND_URL=$(oc get route backend -o jsonpath='{.spec.host}')
echo "Backend: http://$BACKEND_URL"