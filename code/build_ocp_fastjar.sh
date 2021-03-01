#!/bin/sh
echo "Build Backend App with fast-jar"
APP_NAME=backend
mvn clean package -DskipTests=true

echo "Create build config with binary mode and patch with Quarkus Dockerfile"
oc new-build --binary --name=${APP_NAME} -l app=${APP_NAME}
oc patch bc/${APP_NAME} -p "{\"spec\":{\"strategy\":{\"dockerStrategy\":{\"dockerfilePath\":\"src/main/docker/Dockerfile.jvm\"}}}}"

clear
echo "Start build..."
oc start-build ${APP_NAME} --from-dir=. --follow

clear
echo "Create Application"
oc new-app --image-stream=${APP_NAME} \
--labels=app.openshift.io/runtime=quarkus,app.openshift.io/runtime-version=11,app.kubernetes.io/part-of=Demo

clear
echo "Set readiness and liveness probe"
oc rollout pause deployment ${APP_NAME}
oc set probe deployment/${APP_NAME} --readiness --get-url=http://:8080/q/health/ready --initial-delay-seconds=15 --failure-threshold=1 --period-seconds=10
oc set probe deployment/${APP_NAME} --liveness --get-url=http://:8080/q/health/live --initial-delay-seconds=10 --failure-threshold=3 --period-seconds=10

echo "Create configmap"
oc create configmap ${APP_NAME} --from-file=config/application.properties
oc set volume deployment/${APP_NAME} --add --name=${APP_NAME}-config \
--mount-path=/deployments/config/application.properties \
--sub-path=application.properties \
--configmap-name=${APP_NAME}
oc expose svc ${APP_NAME}
oc rollout resume deployment ${APP_NAME}
BACKEND_URL=$(oc get route backend -o jsonpath='{.spec.host}')
echo "Backend: http://${BACKEND_URL}"
