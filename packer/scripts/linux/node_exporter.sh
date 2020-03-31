#!/bin/bash

apt-get install -y -qq prometheus-node-exporter=${EXPORTER_VERSION}

apt-mark hold prometheus-node-exporter

systemctl enable prometheus-node-exporter
