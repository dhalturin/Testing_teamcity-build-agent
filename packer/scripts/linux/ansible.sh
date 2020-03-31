#!/bin/bash

apt-get install -y -qq ansible=${ANSIBLE_VERSION}

apt-mark hold ansible 
