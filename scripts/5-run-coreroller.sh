#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


# Check COREOS_VERSION
@test "Start CoreRoller update dashboard as a docker container" {
  sudo docker run -d \
  --name=coreroller \
  -p 8000:8000 \
  coreroller/demo
}

