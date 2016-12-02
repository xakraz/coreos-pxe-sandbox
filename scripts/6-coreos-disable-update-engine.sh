#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


@test "Disabling CoreOS update-engine" {
  sudo systemctl stop update-engine.service
  sudo systemctl mask update-engine.service
}

