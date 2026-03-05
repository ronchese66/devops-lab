#!/bin/bash

set -e

useradd -m -s /bin/bash jenkins

mkdir -p /home/jenkins/.ssh
cat /tmp/id_ed25519.pub > /home/jenkins/.ssh/authorized_keys
chmod 700 /home/jenkins/.ssh
chmod 600 /home/jenkins/.ssh/authorized_keys
chown -R jenkins:jenkins /home/jenkins/.ssh

groupadd -g 2000 jenkins-shared
usermod -aG jenkins-shared jenkins

mkdir -p /home/jenkins/jenkins_workspace
chown -R jenkins:jenkins-shared /home/jenkins/jenkins_workspace
chmod 2770 /home/jenkins/jenkins_workspace