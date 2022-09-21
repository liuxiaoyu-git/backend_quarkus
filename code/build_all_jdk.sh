#!/bin/bash
mvn clean package -DskipTests=true

#IMAGES="ubi8 ubi8-openjdk-11-runtime ubi9-openjdk-11-runtime ubi8-openjdk-11-runtime-updated 11-ubuntu 11-openjdk 11-mariner 11-jdk-slim-bullseye"
IMAGES="ubi8 ubi8-openjdk-11-runtime ubi9-openjdk-11-runtime ubi8-openjdk-11-runtime-updated"
rm -f trivy-scan-result.txt
for IMAGE in $IMAGES; do
    printf "************ Build $IMAGE ************\n"
    podman build --platform linux/amd64 \
    -f src/main/docker/Dockerfile.$IMAGE -t quay.io/voravitl/backend:$IMAGE .
    podman push quay.io/voravitl/backend:$IMAGE
    printf "************ Scan $IMAGE ************\n"
    trivy image --ignore-unfixed --security-checks vuln quay.io/voravitl/backend:$IMAGE >> trivy-scan-result.txt
done



# for IMAGE in $IMAGES; do
# printf "************ Copy $IMAGE ************\n"
#    skopeo copy \
#     --src-tls-verify=false \
#     --dest-tls-verify=false \
#     --src-no-creds \
#     --dest-creds admin:P@ssw0rd@1 \
#     docker://quay.io/voravitl/backend:$IMAGE \
#     docker://nexus-registry-ci-cd.apps.cluster-zfzkr.zfzkr.sandbox1075.opentlc.com/backend:$IMAGE

# done



# ROX_CLI="podman run --platform linux/amd64 -it registry.redhat.io/advanced-cluster-security/rhacs-roxctl-rhel8:3.71.0"
# ROX_CENTRAL_ADDRESS=$(oc get route central -n stackrox -o jsonpath='{.spec.host}'):443
# REGISTRY=$(oc get -n ci-cd route nexus-registry -o jsonpath='{.spec.host}')
# rm -f acs.txt
# allImages=(ubi8 ubi8-openjdk-11-runtime ubi9-openjdk-11-runtime ubi8-openjdk-11-runtime-updated 11-ubuntu 11-openjdk 11-mariner 11-jdk-slim-bullseye)
# for image in $allImages
# do
#     roxctl \
#     --insecure-skip-tls-verify -e $ROX_CENTRAL_ADDRESS \
#     image check \
#     --image $REGISTRY/backend:$image --output=table >> acs.txt
# done


