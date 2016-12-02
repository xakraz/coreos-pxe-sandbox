#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


@test "Check Mayu container is running" {
  run docker inspect -f '{{ .State.Status }}' mayu
  [ "${lines[0]}" = "running" ]
}

@test "Check Mayu service is working" {
  run ${ARTIFACT_DIR}/mayuctl --no-tls list
  [ $status -eq 0 ]
}

@test "Check CoreRoller container is running" {
  run docker inspect -f '{{ .State.Status }}' coreroller
  [ "${lines[0]}" = "running" ]
}

@test "Check network is reachable" {
  result="$(sudo iptables -L -t nat | grep -i -c masquerade)"

  # Masquerade 1 = Docker rule
  # Masquerade 2 = Ours
  [ "$result" == '3'  ]
}

@test "Check update-engine is stopped" {
  run sudo systemctl status update-engine.service
  [[ "${lines[1]}" =~ "Loaded: masked" ]]
  [[ "${lines[2]}" =~ "Active: failed" ]]
}

