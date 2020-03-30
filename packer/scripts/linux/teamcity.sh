#!/bin/bash -eux

apt-get install -y -qq unzip openjdk-8-jdk mercurial git

useradd -m teamcity

wget ${TC_SERVER}/update/buildAgent.zip -O /tmp/tc-agent.zip
unzip /tmp/tc-agent.zip -d /opt/tc-agent

chown teamcity: -R /opt/tc-agent

mv /opt/tc-agent/conf/buildAgent{.dist,}.properties

sed -i "s|^serverUrl=.*|serverUrl=${TC_SERVER}|" /opt/tc-agent/conf/buildAgent.properties

cat > /etc/systemd/system/tc-agent.service <<EOF
[Unit]
Description=TeamCity Build Agent
After=network.target

[Service]
Type=oneshot

User=teamcity
Group=teamcity

ExecStart=/opt/tc-agent/bin/agent.sh start
ExecStop=-/opt/tc-agent/bin/agent.sh stop

PIDFile=/opt/tc-agent/logs/buildAgent.pid

# Support agent upgrade as the main process starts a child and exits then
RemainAfterExit=yes

# Support agent upgrade as the main process gets SIGTERM during upgrade and that maps to exit code 143
SuccessExitStatus=0 143

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable tc-agent
