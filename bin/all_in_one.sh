#!/bin/sh
banner (){
    echo ""
    echo "***********************************************************************************"
    echo "${1}"
    echo "***********************************************************************************"
    read -p ""
}
./setup_projects.sh
./setup_maven36_slave.sh
./setup_ci_cd_tools.sh
banner "Pess any key to create pipelines"
./create_pipelines.sh
