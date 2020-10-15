#!/bin/sh
banner (){
    echo ""
    echo "***********************************************************************************"
    echo "${1}"
    echo "***********************************************************************************"
    sleep 3
}
banner "Create ci-cd,dev,stage,uat and prod project"
./setup_projects.sh
banner "Build jenkins slave with maven36"
./setup_maven36_slave.sh
banner "Start build CI/CD Tools"
./setup_ci_cd_tools_ocp45.sh
banner "Create pipelines for backend app (Quarkus)"
./create_pipelines.sh
