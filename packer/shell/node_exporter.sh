#!/bin/bash

apt-get install -y -qq prometheus-node-exporter

# apt-get update

systemctl enable prometheus-node-exporter
