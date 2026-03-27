#!/bin/bash

# Update system
apt update -y

# Install basic tools
apt install -y curl unzip git

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -LO https://amazon-eks.s3.us-west-2.amazonaws.com/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# Configure EKS
aws eks update-kubeconfig \
  --region ${region} \
  --name ${cluster_name}

  

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# Install eksctl
# 1. Download the latest release
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# 2. Move the binary to /usr/local/bin
mv /tmp/eksctl /usr/local/bin

# 3. Verify installation
eksctl version


echo "DONE"