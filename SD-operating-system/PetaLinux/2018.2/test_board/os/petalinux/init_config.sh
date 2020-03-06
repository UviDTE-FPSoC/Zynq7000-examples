#!/bin/sh

# Script changes absolute path of config to current project path
# see: https://wiki.trenz-electronic.de/display/PD/PetaLinux+KICKstart
csplit project-spec/configs/config '/CONFIG_TMP_DIR_LOCATION/'
mv xx00 project-spec/configs/config
echo CONFIG_TMP_DIR_LOCATION=\"${PWD}/build/tmp\" >> project-spec/configs/config
sed '/CONFIG_TMP_DIR_LOCATION/d' xx01 >> project-spec/configs/config
rm -rf xx01

