#!/bin/bash
./setup_ci_cd_tools.sh
./setup_projects.sh
./setup_maven36_slave.sh
./create_pipelines.sh
echo "#####################################################"
echo "Login to https://$(oc get route nexus -n ci-cd -o jsonpath='{.spec.host}')"
echo "User ID: admin"
echo "Password: $(cat ./nexus_password.txt)"
echo "Change password to password1234"
echo "Enable Anonymous access"
rm ./nexus_password.txt
echo "#####################################################"
