#!/usr/bin/env bash

cd HelloworldDemo
printf '\n\nBuilding the Java Spring Boot Web!\n\n'
mvn clean verify
if [ $? -ne 0 ]; then
  printf '\n\nJava application build failed!i\n'
  exit -1
fi

cd ..
printf '\n\nStarting the Terraforming!\n\n'
cd terraform
terraform plan -out=plan.out
terraform apply plan.out
