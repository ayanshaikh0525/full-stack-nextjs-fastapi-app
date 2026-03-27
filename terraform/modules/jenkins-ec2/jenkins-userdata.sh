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
apt install fontconfig openjdk-21-jre
java -version

# ----------------------------
# Install Jenkins
# ----------------------------
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null


sudo apt update
sudo apt install jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

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
curl -LO https://amazon-eks.s3.us-east-1.amazonaws.com/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

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