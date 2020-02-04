#!/bin/bash
./setup_ci_cd_tools.sh
./setup_projects.sh
./setup_maven36_slave.sh
#./setup_maven36_graalvm_slave.sh
./create_pipelines.sh
