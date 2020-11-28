#!/bin/sh
#
# creates necessary routing rules

# store backup of current iptables
iptables-save > /default-tables.backup

# flush all chains
iptables -F
# default deny all
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow unlimited traffic on the loopback interface
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT

# Allow outgoing icmp connections (pings)
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT  -p icmp -m state --state ESTABLISHED,RELATED     -j ACCEPT

# Allow already established stuff
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
# UDP
iptables -A INPUT -i eth0 -p udp --sport 53 -m state \
    --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --dport 53 -m state \
    --state NEW,ESTABLISHED -j ACCEPT
# TCP
iptables -A INPUT -i eth0 -p tcp --sport 53 -m state \
    --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 53 -m state \
    --state NEW,ESTABLISHED -j ACCEPT

# Allow outgoing HTTP
# Incoming
# iptables -A INPUT -i eth0 -p tcp --dport 80 -m state \
#    --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state \
#     --state ESTABLISHED -j ACCEPT
# Outgoing
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state \
    --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state \
    --state NEW,ESTABLISHED -j ACCEPT

# Allow outgoing HTTPS
# Incoming
# iptables -A INPUT -i eth0 -p tcp --dport 443 -m state \
#     --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state \
#     --state ESTABLISHED -j ACCEPT
# Outgoing
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state \
    --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state \
    --state NEW,ESTABLISHED -j ACCEPT


# simply print interface and gateway that can connect to the internet
# host we want to "reach"
# host=google.com
# get the ip of that host (works with dns and /etc/hosts. In case we get
# multiple IP addresses, we just want one of them
# host_ip=$(getent ahosts "$host" | awk '{print $1; exit}')
# INTERFACE=$(ip route get "$host_ip" | grep -Po '(?<=(dev )).*(?= src| proto)')
# GATEWAY=$(ip route get "$host_ip" | awk {'print $3; exit'})

# OPENVPN
iptables -A INPUT -i eth0 -p $OPENVPN_PROTOCOL_TYPE -m state \
    --state NEW,ESTABLISHED --dport 1194 -j ACCEPT
iptables -A OUTPUT -o eth0 -p $OPENVPN_PROTOCOL_TYPE -m state \
    --state ESTABLISHED --sport 1194 -j ACCEPT
# route requests
iptables -A FORWARD -i tun0 -o eth0 -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# masquerade traffic over our iface that is connected to the internet
iptables -t nat -A POSTROUTING -o eth0 -s 10.8.0.0/24 -j MASQUERADE
