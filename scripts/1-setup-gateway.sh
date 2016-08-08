#!/usr/bin/env bats
# vim: ft=sh:sw=2:et

@test "Load iptables_nat kernel module" {
  modprobe iptable_nat
}

@test "Activate IP_FORWARD" {
  echo 1 > /proc/sys/net/ipv4/ip_forward
}

@test "IPTABLES: Forward input from  private_network" {
  iptables -A FORWARD -i eth1 -j ACCEPT
}

@test "IPTABLES: NAT output on VBox default network" {
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}
