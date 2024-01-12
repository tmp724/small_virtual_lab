#! /bin/bash

# remove potential old lab
ip link del veth0
ip link del veth1
ip netns del ns0
ip netns del ns1

# create small virtual network lab; two network namespaces connected via a veth pair
## create veth pair
ip link add veth0 type veth peer name veth1
## create network namespaces
ip netns add ns0
ip netns add ns1
## add veth interfaces to namespaces
ip link set veth0 netns ns0
ip link set veth1 netns ns1
## set mac addresses
ip netns exec ns0 ip link set dev veth0 address 00:00:00:00:00:01
ip netns exec ns1 ip link set dev veth1 address 00:00:00:00:00:02
## get up interfaces
ip netns exec ns0 ip link set veth0 up
ip netns exec ns1 ip link set veth1 up
## configure ipv4 address
ip netns exec ns0 ip addr add 10.0.0.1/24 dev veth0
ip netns exec ns1 ip addr add 10.0.0.2/24 dev veth1
## disable ipv6 address (to reduce noise)
ip netns exec ns0 sysctl -w net.ipv6.conf.veth0.disable_ipv6=1
ip netns exec ns1 sysctl -w net.ipv6.conf.veth1.disable_ipv6=1

## look at traffic
xterm -e "ip netns exec ns0 tshark --color -V" &
xterm -e "ip netns exec ns1 tshark --color -V" &

