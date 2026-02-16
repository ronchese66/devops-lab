#!/bin/bash

set -e

useradd -m -s /bin/bash -u 2000 jenkins
mkdir -p /home/jenkins/.ssh

cat /tmp/id_ed25519.pub > /home/jenkins/.ssh/authorized_keys
chmod 700 /home/jenkins/.ssh
chmod 600 /home/jenkins/.ssh/authorized_keys
chown -R jenkins:jenkins /home/jenkins/.ssh

mkdir -p /opt/jenkins_workspace
chown -R jenkins:jenkins /opt/jenkins_workspace