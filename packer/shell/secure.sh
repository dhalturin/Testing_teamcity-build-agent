#!/bin/bash

apt-get install -y -qq iptables-persistent

cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [16:1472]
-I INPUT -i lo -j ACCEPT
-I INPUT -p tcp -m multiport --dports 22,9100,9090 -j ACCEPT
-I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
COMMIT
EOF

