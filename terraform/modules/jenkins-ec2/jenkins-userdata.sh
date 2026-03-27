#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install basic packages
apt-get install -y curl wget unzip gnupg software-properties-common apt-transport-https ca-certificates

# ----------------------------
# Install Java (required for Jenkins)
# ----------------------------
apt install -y fontconfig openjdk-21-jre
java -version

# ----------------------------
# Install Jenkins
# ----------------------------
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null


apt update -y
apt install jenkins -y

systemctl enable jenkins
systemctl start jenkins
systemctl status jenkins

# ----------------------------
# Install Docker
# ----------------------------
apt-get install -y docker.io

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu
usermod -aG docker jenkins

# ----------------------------
# Install AWS CLI v2
# ----------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# ----------------------------
# Install kubectl (EKS compatible)
# ----------------------------
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.15/2026-02-27/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/


# Install eksctl
# 1. Download the latest release
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# 2. Move the binary to /usr/local/bin
mv /tmp/eksctl /usr/local/bin

# 3. Verify installation
eksctl version



# ----------------------------
# Clean up
# ----------------------------
apt-get clean

# ----------------------------
# Output Jenkins initial password
# ----------------------------
echo "Jenkins setup complete"
echo "Initial Admin Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword