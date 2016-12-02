#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


@test "Remove update-engine / Locksmith management" {
  run sudo sed -i '5,11d;' /var/lib/coreos-install/user_data
  [ $status -eq 0 ]
}


@test "Change update-engine reboot-strategy" {
  run sudo sed -i 's/reboot-strategy: off/reboot-strategy: etcd-lock/' /var/lib/coreos-install/user_data
  [ $status -eq 0 ]
}
